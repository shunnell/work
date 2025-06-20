from pathlib import Path
import argparse
import json
from glob import glob
from pprint import pprint

def get_file_paths(in_dir: Path):
    for path in glob("**/tfplan.json", root_dir=in_dir, recursive=True):
        yield Path(path)

def sanitize(search_dict):
    """
    Takes a dict with nested lists and dicts,
    and sanitizes sensitive changes.
    """
    for key, value in search_dict.items():
        if key == "before_sensitive":
            search_dict[key] = "[redacted]"
        elif key == "after_sensitive":
            search_dict[key] = "[redacted]"
        elif isinstance(value, dict):
            sanitize(value)
        elif isinstance(value, list):
            for item in value:
                if isinstance(item, dict):
                    sanitize(item)

def load_json(myjson):
    try:
        return json.loads(myjson)
    except ValueError as e:
        print(f"DEBUG: not json:")
        pprint(myjson)
    return json.loads("{}")

def main(directory: str, output: str):
    directory = Path(directory).resolve()
    if not directory.is_dir():
        exit(f"Supplied directory {directory} is not a directory")
    json_files = sorted(get_file_paths(directory))
    print(f"Found {len(json_files)} files:\n\t{'\n\t'.join([str(f) for f in json_files])}")
    create = 0
    update = 0
    delete = 0
    read = 0
    no_op = 0
    changes = dict()
    for file in json_files:
        print(f"Loading '{str(file)}'...")
        json_data = load_json((directory / file).read_text())
        r_changes = json_data.get("resource_changes") or []
        o_changes = json_data.get("output_changes") or {}
        changes[str(file.parent)] = dict(
            resource_changes = r_changes,
            output_changes = o_changes,
        )
        for change in r_changes:
            action = change["change"]["actions"]
            create = create + action.count("create")
            update = update + action.count("update")
            delete = delete + action.count("delete")
            read = read + action.count("read")
            no_op = no_op + action.count("no-op")
        for key, change in o_changes.items():
            action = change["actions"]
            create = create + action.count("create")
            update = update + action.count("update")
            delete = delete + action.count("delete")
            read = read + action.count("read")
            no_op = no_op + action.count("no-op")
    changes["create"] = create
    changes["update"] = update
    changes["delete"] = delete
    changes["read"] = read
    changes["no-op"] = no_op
    sanitize(changes)
    Path(output).write_text(json.dumps(changes))
    print(f"CHANGES:")
    print(json.dumps(changes, indent=2))

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        prog='TerraformPlanFormatter',
        description='Formats terraform plans for CICD output')
    parser.add_argument('--directory')
    parser.add_argument('--output')
    args = parser.parse_args()
    main(args.directory, args.output)
