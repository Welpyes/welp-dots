#!/usr/bin/env python3
import subprocess, json, sys

def get_workspaces():
    process = subprocess.Popen(['bspc', 'subscribe', 'report'], stdout=subprocess.PIPE, text=True)
    
    for line in process.stdout:
        parts = line.strip().split(':')
        workspaces = []
        
        for part in parts:
            if not part: continue
            state, name = part[0], part[1:]
            
            if state.lower() in 'fou':
                status = "empty"
                if state.lower() == 'o': status = "occupied"
                if state.lower() == 'u': status = "urgent"
                
                workspaces.append({
                    "name": name,
                    "status": status,
                    "focused": state.isupper()
                })
        
        print(json.dumps(workspaces), flush=True)

if __name__ == "__main__":
    try:
        get_workspaces()
    except KeyboardInterrupt:
        sys.exit(0)
