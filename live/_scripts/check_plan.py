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

def main(directory: str, output: str):
    directory = Path(directory).resolve()
    if not directory.is_dir():
        exit(f"Supplied directory {directory} is not a directory")
    json_files = sorted(get_file_paths(directory))
    print(f"Found {len(json_files)} files:\n\t{'\n\t'.join([str(f) for f in json_files])}")
    changes = dict(
        create = 0,
        update = 0,
        delete = 0,
    )
    for file in json_files:
        json_data = json.loads((directory / file).read_text())
        # print(f"DEBUG: Read {file}, got:")
        # pprint(json_data)
        r_changes = json_data.get("resource_changes") or []
        o_changes = json_data.get("output_changes") or {}
        changes[str(file.parent)] = dict(
            resource_changes = r_changes,
            output_changes = o_changes,
        )
        for change in r_changes:
            action = change["change"]["actions"]
            changes["create"] = changes["create"] + action.count("create")
            changes["update"] = changes["update"] + action.count("update")
            changes["delete"] = changes["delete"] + action.count("delete")
        for key, change in o_changes.items():
            action = change["actions"]
            changes["create"] = changes["create"] + action.count("create")
            changes["update"] = changes["update"] + action.count("update")
            changes["delete"] = changes["delete"] + action.count("delete")
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
