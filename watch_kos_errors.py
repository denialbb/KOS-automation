import argparse
import asyncio
import json
import re
import hashlib
import sys
import os
from collections import deque
from datetime import datetime, timezone
from enum import Enum, auto

RE_KSP_LINE = re.compile(r'^\[(?P<tag>[A-Z]{3})\s+(?P<ts>[\d:.]+)\]\s*(?P<msg>.*)$')
RE_KOS = re.compile(r'(?i)\bkOS\b|kos\.|KOSException|KOSScript|kos:|IOException|Ships\\Script|telemetry\.json')
RE_ERROR = re.compile(r'(?i)\b(error|nre)\b|exception|\[ERR\b|\[EXC\b|NullReference|IndexOutOfRange|InvalidOperation|ArgumentException|UnityException|KeyNotFoundException|StackOverflow|OutOfMemory')
RE_STACK = re.compile(r'^  at |^\s+at |^\s+---\s|^UnityEngine\.|^System\.|^kOS\.|^\[LOG.*?\] Code Fragment|^File\s+Line:Col|^====|^[a-zA-Z0-9_]+:/')

class ParserState(Enum):
    IDLE = auto()
    COLLECTING_STACK = auto()

def get_severity(tag: str) -> str:
    if tag == 'EXC': return 'exception'
    if tag == 'ERR': return 'error'
    if tag == 'WRN': return 'warning'
    return 'info'

def get_message_hash(text: str) -> str:
    return hashlib.sha256(text.encode('utf-8')).hexdigest()[:16]

def emit(event_dict: dict):
    print(json.dumps(event_dict, separators=(',', ':')), flush=True)

async def heartbeat_task(heartbeat_sec: int, get_error_count):
    if heartbeat_sec <= 0:
        return
    while True:
        await asyncio.sleep(heartbeat_sec)
        emit({
            "event": "heartbeat",
            "at": datetime.now(timezone.utc).isoformat(),
            "errors_so_far": get_error_count()
        })

async def main():
    parser = argparse.ArgumentParser(description="Watch KSP log for kOS errors")
    parser.add_argument("--log-path", default=r"C:\Program Files (x86)\Steam\steamapps\common\Kerbal Space Program\KSP.log")
    parser.add_argument("--tail-lines", type=int, default=200)
    parser.add_argument("--context-lines", type=int, default=5)
    parser.add_argument("--stack-lines", type=int, default=20)
    parser.add_argument("--heartbeat-sec", type=int, default=30)
    parser.add_argument("--dedupe-window", type=int, default=50)
    parser.add_argument("--watch", action="store_true")
    parser.add_argument("--extract-all", action="store_true", help="Scan the entire log file from the beginning and exit")
    args = parser.parse_args()

    if not os.path.exists(args.log_path):
        emit({
            "event": "fatal",
            "at": datetime.now(timezone.utc).isoformat(),
            "message": "KSP.log not found at the specified path.",
            "path": args.log_path
        })
        sys.exit(1)

    emit({
        "event": "started",
        "at": datetime.now(timezone.utc).isoformat(),
        "log_path": args.log_path,
        "watch_mode": args.watch,
        "extract_all": args.extract_all,
        "tail_lines": args.tail_lines
    })

    error_count = 0
    context_buf = deque(maxlen=args.context_lines + 1)
    dedupe_set = set()
    dedupe_order = deque()

    state = ParserState.IDLE
    stack_capture = []
    pending_event = None

    with open(args.log_path, 'r', encoding='utf-8', errors='replace') as f:
        async def line_reader():
            if args.extract_all:
                f.seek(0)
                for line in f:
                    yield line
            elif args.tail_lines > 0:
                for line in deque(f, maxlen=args.tail_lines):
                    yield line
            else:
                f.seek(0, os.SEEK_END)
            
            if args.watch:
                while True:
                    line = f.readline()
                    if not line:
                        await asyncio.sleep(0.1)
                        continue
                    yield line

        heartbeat = None
        if args.watch:
            heartbeat = asyncio.create_task(heartbeat_task(args.heartbeat_sec, lambda: error_count))
            
        try:
            async for line in line_reader():
                raw = line.rstrip('\n\r')

                if state == ParserState.COLLECTING_STACK:
                    if RE_STACK.match(raw) and len(stack_capture) < args.stack_lines:
                        stack_capture.append(raw.strip())
                        continue
                    
                    pending_event["stack_trace"] = list(stack_capture)
                    emit(pending_event)
                    state = ParserState.IDLE
                    stack_capture.clear()
                    pending_event = None
                
                context_buf.append(raw)

                if not (RE_KOS.search(raw) and RE_ERROR.search(raw)):
                    continue

                m = RE_KSP_LINE.match(raw)
                tag = m.group('tag') if m else 'UNK'
                ts = m.group('ts') if m else ''
                msg = m.group('msg') if m else raw

                hash_val = get_message_hash(msg)
                if hash_val in dedupe_set:
                    continue

                dedupe_set.add(hash_val)
                dedupe_order.append(hash_val)
                if len(dedupe_order) > args.dedupe_window:
                    evicted = dedupe_order.popleft()
                    dedupe_set.remove(evicted)
                
                error_count += 1
                ctx = list(context_buf)[:-1]

                pending_event = {
                    "event": "kos_error",
                    "index": error_count,
                    "at": datetime.now(timezone.utc).isoformat(),
                    "severity": get_severity(tag),
                    "ksp_tag": tag,
                    "ksp_time": ts,
                    "message": msg,
                    "context": ctx,
                    "stack_trace": [],
                    "raw_line": raw
                }
                state = ParserState.COLLECTING_STACK
                
            if state == ParserState.COLLECTING_STACK and pending_event is not None:
                pending_event["stack_trace"] = list(stack_capture)
                emit(pending_event)
                
        except asyncio.CancelledError:
            pass
        except Exception as e:
            emit({
                "event": "script_error",
                "at": datetime.now(timezone.utc).isoformat(),
                "message": str(e),
                "source": "main_loop"
            })
            sys.exit(1)
        finally:
            if heartbeat:
                heartbeat.cancel()
            emit({
                "event": "stopped",
                "at": datetime.now(timezone.utc).isoformat(),
                "total_errors": error_count
            })

if __name__ == '__main__':
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        pass
