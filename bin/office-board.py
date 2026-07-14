#!/usr/bin/env python3

# =============================================================================
# Authors:      Román García Guill
# Contact:      romangarciaguill@gmail.com
# Created:      Sun 05. Jul 2026
#
# Purpose:      Set the different work env inside a tmux session.
# =============================================================================

import subprocess
from pathlib import Path
from dataclasses import dataclass

PROJECT_DIR = Path.home() / "Tools" / "tmux" / "sessions"


@dataclass(slots=True)
class Project:
    name: str
    file: Path


SPACING = 40

MENU = ["view options", "create project", "delete project"]


def get_projects(directory: Path = PROJECT_DIR) -> list[Project]:
    projects: list[Project] = []
    for file in sorted(directory.iterdir()):
        if file.is_file():
            projects.append(
                Project(
                    name=file.stem,
                    file=file,
                )
            )
    return projects


def view_projects(directory: Path = PROJECT_DIR) -> list[Project]:
    subprocess.run(["clear"], check=False)
    print("-" * SPACING)
    print(f"{'OFFICE PROJECTS':^{SPACING}}")
    print("-" * SPACING)

    projects = get_projects(PROJECT_DIR)
    if not projects:
        print("No projects found.")
        return []
    for index, project in enumerate(projects, start=1):
        print(f"{index:>2} {project.name}")
    return projects


def new_project():
    pass


def unalive_project():
    pass


def open_project(project: Project):
    pass


###############################################################################
# %% Main


def main() -> None:
    select_options(MENU)
    view_projects(PROJECT_DIR)


if __name__ == "__main__":
    main()
