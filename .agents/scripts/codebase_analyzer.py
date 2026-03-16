#!/usr/bin/env python3
"""
Codebase Analyzer - Helper utilities for analyzing project structure and code
"""

import os
import pathlib
import json
import re
from typing import Dict, List, Optional, Tuple
from collections import defaultdict
import logging
from pathlib import Path

# --- Logging Setup ---
try:
    WORKSPACE_ROOT = Path(__file__).parents[3]
    LOG_DIR = WORKSPACE_ROOT / ".agent" / "mcp_logs"
    LOG_DIR.mkdir(parents=True, exist_ok=True)

    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
        handlers=[
            logging.FileHandler(LOG_DIR / "analysis.log"),
            logging.StreamHandler(),
        ],
    )
    logger = logging.getLogger("codebase-analyzer")
except Exception as e:
    logging.basicConfig(level=logging.INFO)
    logger = logging.getLogger("codebase-analyzer")


class CodebaseAnalyzer:
    """Analyze project structure, detect frameworks, and extract metadata"""

    FRAMEWORK_PATTERNS = {
        'django': ['manage.py', 'settings.py', 'wsgi.py'],
        'flask': ['app.py', 'wsgi.py', 'requirements.txt'],
        'fastapi': ['main.py', 'requirements.txt'],
        'react': ['package.json', 'src/App.jsx', 'src/index.jsx'],
        'next.js': ['next.config.js', 'pages/', 'package.json'],
        'vue': ['vue.config.js', 'src/App.vue', 'package.json'],
        'angular': ['angular.json', 'src/app/'],
        'express': ['package.json', 'app.js', 'server.js'],
        'nestjs': ['nest-cli.json', 'package.json'],
        'rails': ['Gemfile', 'config/routes.rb', 'app/'],
        'laravel': ['composer.json', 'artisan', 'app/Http/'],
        'spring': ['pom.xml', 'src/main/java/'],
    }

    LANGUAGE_EXTENSIONS = {
        '.py': 'Python', '.js': 'JavaScript', '.ts': 'TypeScript',
        '.jsx': 'React/JSX', '.tsx': 'TypeScript/React', '.java': 'Java',
        '.rb': 'Ruby', '.php': 'PHP', '.go': 'Go', '.rs': 'Rust',
        '.cs': 'C#', '.cpp': 'C++', '.c': 'C', '.swift': 'Swift',
        '.kt': 'Kotlin',
    }

    CONFIG_FILES = [
        'package.json', 'requirements.txt', 'Pipfile', 'pyproject.toml',
        'Gemfile', 'composer.json', 'pom.xml', 'build.gradle',
        'go.mod', 'Cargo.toml', '.env.example', 'docker-compose.yml',
        'Dockerfile', '.gitignore', 'README.md'
    ]

    def __init__(self, project_root: str):
        """Initialize analyzer with project root path"""
        self.project_root = pathlib.Path(project_root).resolve()
        self.ignore_dirs = {
            '.git', 'node_modules', '__pycache__', 'venv',
            'env', 'dist', 'build', '.next', '.cache',
            '.venv', '.idea', '.vscode'
        }
        logger.info(f"Initialized CodebaseAnalyzer for {self.project_root}")

    def detect_project_type(self) -> str:
        """Detect if project is brownfield or greenfield"""
        source_files = self._count_source_files()

        if source_files > 5:
            return "brownfield"
        elif source_files > 0:
            return "minimal"
        else:
            return "greenfield"

    def detect_framework(self) -> List[str]:
        """Detect framework(s) used in the project"""
        detected = []

        for framework, patterns in self.FRAMEWORK_PATTERNS.items():
            if self._check_patterns(patterns):
                detected.append(framework)

        return detected if detected else ['unknown']

    def detect_languages(self) -> Dict[str, int]:
        """Detect programming languages and count files"""
        language_counts = defaultdict(int)

        for ext, language in self.LANGUAGE_EXTENSIONS.items():
            count = len(list(self.project_root.rglob(f'*{ext}')))
            if count > 0:
                language_counts[language] = count

        return dict(language_counts)

    def scan_structure(self, max_depth: int = 3) -> Dict:
        """Scan project directory structure"""
        structure = {
            'root': str(self.project_root),
            'directories': [],
            'files': [],
            'config_files': [],
        }

        for item in self.project_root.rglob('*'):
            if any(ignored in item.parts for ignored in self.ignore_dirs):
                continue

            rel_path = item.relative_to(self.project_root)

            if len(rel_path.parts) > max_depth:
                continue

            if item.is_dir():
                structure['directories'].append(str(rel_path))
            else:
                structure['files'].append(str(rel_path))

                if item.name in self.CONFIG_FILES:
                    structure['config_files'].append(str(rel_path))

        logger.debug(f"Scanned structure: {len(structure['files'])} files, {len(structure['directories'])} dirs")
        return structure

    def find_entry_points(self) -> List[str]:
        """Find main entry points of the application"""
        entry_point_patterns = [
            'main.py', 'app.py', 'server.py', 'manage.py',
            'index.js', 'server.js', 'app.js', 'main.ts',
            'Main.java', 'Program.cs', 'main.go', 'main.rs'
        ]

        entry_points = []
        for pattern in entry_point_patterns:
            matches = list(self.project_root.rglob(pattern))
            for m in matches:
                if any(ignored in m.parts for ignored in self.ignore_dirs):
                    continue
                entry_points.append(str(m.relative_to(self.project_root)))

        return entry_points

    def extract_dependencies(self) -> Dict[str, List[str]]:
        """Extract dependencies from manifest files"""
        dependencies = {}

        if (self.project_root / 'requirements.txt').exists():
            deps = self._parse_requirements()
            if deps:
                dependencies['python'] = deps

        package_json = self.project_root / 'package.json'
        if package_json.exists():
            deps = self._parse_package_json()
            if deps:
                dependencies['javascript'] = deps

        gemfile = self.project_root / 'Gemfile'
        if gemfile.exists():
            dependencies['ruby'] = ['See Gemfile']

        pom_xml = self.project_root / 'pom.xml'
        if pom_xml.exists():
            dependencies['java'] = ['See pom.xml']

        return dependencies

    def analyze_complexity(self) -> Dict:
        """Analyze code complexity metrics"""
        metrics = {
            'total_files': 0,
            'total_lines': 0,
            'avg_file_size': 0,
            'largest_files': [],
        }

        file_sizes = []

        for ext in self.LANGUAGE_EXTENSIONS.keys():
            for file in self.project_root.rglob(f'*{ext}'):
                if any(ignored in file.parts for ignored in self.ignore_dirs):
                    continue

                try:
                    lines = len(file.read_text().splitlines())
                    metrics['total_files'] += 1
                    metrics['total_lines'] += lines
                    file_sizes.append((str(file.relative_to(self.project_root)), lines))
                except Exception:
                    pass

        if metrics['total_files'] > 0:
            metrics['avg_file_size'] = metrics['total_lines'] // metrics['total_files']
            metrics['largest_files'] = sorted(file_sizes, key=lambda x: x[1], reverse=True)[:10]

        return metrics

    # Private helper methods

    def _count_source_files(self) -> int:
        """Count source code files"""
        count = 0
        for ext in self.LANGUAGE_EXTENSIONS.keys():
            count += len(list(self.project_root.rglob(f'*{ext}')))
        return count

    def _check_patterns(self, patterns: List[str]) -> bool:
        """Check if patterns exist in project"""
        for pattern in patterns:
            path = self.project_root / pattern
            if path.exists():
                return True
        return False

    def _parse_requirements(self) -> List[str]:
        """Parse Python requirements.txt"""
        req_file = self.project_root / 'requirements.txt'
        try:
            content = req_file.read_text()
            deps = []
            for line in content.splitlines():
                line = line.strip()
                if line and not line.startswith('#'):
                    match = re.match(r'^([a-zA-Z0-9-_]+)', line)
                    if match:
                        deps.append(match.group(1))
            return deps
        except Exception:
            return []

    def _parse_package_json(self) -> List[str]:
        """Parse Node.js package.json"""
        package_json = self.project_root / 'package.json'
        try:
            data = json.loads(package_json.read_text())
            deps = []
            if 'dependencies' in data:
                deps.extend(data['dependencies'].keys())
            if 'devDependencies' in data:
                deps.extend(data['devDependencies'].keys())
            return deps
        except Exception:
            return []


def main():
    """CLI interface for testing"""
    import sys

    if len(sys.argv) < 2:
        print("Usage: python codebase_analyzer.py <project_path>")
        sys.exit(1)

    project_path = sys.argv[1]
    analyzer = CodebaseAnalyzer(project_path)

    print("=" * 60)
    print("Codebase Analysis Report")
    print("=" * 60)

    print(f"\nProject Type: {analyzer.detect_project_type()}")
    print(f"\nFrameworks: {', '.join(analyzer.detect_framework())}")

    print("\nLanguages:")
    for lang, count in analyzer.detect_languages().items():
        print(f"  - {lang}: {count} files")

    print("\nEntry Points:")
    for entry in analyzer.find_entry_points():
        print(f"  - {entry}")

    print("\nDependencies:")
    for ecosystem, deps in analyzer.extract_dependencies().items():
        print(f"  {ecosystem}: {len(deps)} packages")

    metrics = analyzer.analyze_complexity()
    print(f"\nComplexity Metrics:")
    print(f"  Total Files: {metrics['total_files']}")
    print(f"  Total Lines: {metrics['total_lines']:,}")
    print(f"  Avg File Size: {metrics['avg_file_size']} lines")

    if metrics['largest_files']:
        print(f"\nLargest Files:")
        for file, lines in metrics['largest_files'][:5]:
            print(f"  - {file}: {lines} lines")


if __name__ == '__main__':
    main()
