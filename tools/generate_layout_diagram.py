#!/usr/bin/env python3
"""Generate a planning schematic from WorldLayout; never a Studio screenshot."""
import argparse
from html import escape
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]


def generate():
    source = (ROOT / "src/ReplicatedStorage/Shared/WorldLayout.luau").read_text()
    def point(text):
        x, _, z = map(float, text.split(","))
        return x + 300, z + 250
    zones = re.findall(r'Id = "([A-H])", Name = "([^"]+)", Center = Vector3.new\(([^)]+)\), Radius = (\d+)', source)
    centers = {zone: point(position) for zone, _, position, _ in zones}
    routes = re.findall(r'From = "([A-H])", To = "([A-H])", Width = (\d+), Control = Vector3.new\(([^)]+)\)(?:,\s*Via = Vector3.new\(([^)]+)\))?', source)
    assert len(zones) == 8 and len(routes) == 10, "Layout schema changed; update diagram generator"
    svg = ['<svg xmlns="http://www.w3.org/2000/svg" width="980" height="620" viewBox="0 0 980 620">',
           '<rect width="980" height="620" fill="#faf5e8"/>',
           '<g font-family="sans-serif" fill="#294839">',
           '<text x="35" y="30" font-size="22" font-weight="bold">CAPY R1 — authored layout schematic</text>',
           '<text x="35" y="52" font-size="13">Design plan only. Not a Studio screenshot or visual verification.</text>',
           '<g transform="translate(35 75)">',
           '<rect width="600" height="500" rx="8" fill="#92b779" stroke="#496b43" stroke-width="2"/>',
           '<rect x="0" y="0" width="600" height="35" fill="#72998b"/>',
           '<text x="160" y="22" font-size="12">Khao Yai ridge / forest backdrop</text>',
           '<rect x="18" y="36" width="564" height="449" fill="none" stroke="#775a39" stroke-width="3" stroke-dasharray="6 3"/>']
    for zone, _, position, radius in zones:
        x, z = point(position)
        svg.append(f'<ellipse cx="{x}" cy="{z}" rx="{radius}" ry="{float(radius)*.71}" fill="#bcce8a" stroke="#64854e" opacity=".8"/>')
    for a, b, width, control, via in routes:
        x, z = point(via) if via else centers[a]
        cx, cz = point(control)
        bx, bz = centers[b]
        svg.append(f'<path d="M{x},{z} Q{cx},{cz} {bx},{bz}" fill="none" stroke="#e8c98f" stroke-width="{width}" stroke-linecap="round"/>')
    svg.append('<path d="M505,428 L505,485" stroke="#e8c98f" stroke-width="24"/>')
    # Pond lobes are illustrative: this diagram does not render world geometry.
    svg.append('<path d="M53,84 C55,60 100,48 123,69 C140,85 116,110 86,103 C64,110 48,100 53,84" fill="#49b2ce"/>')
    for zone, _, position, _ in zones:
        x, z = point(position)
        svg.extend([f'<circle cx="{x}" cy="{z}" r="11" fill="#37533b"/>',
                    f'<text x="{x}" y="{z+5}" fill="white" text-anchor="middle" font-size="14" font-weight="bold">{zone}</text>'])
    svg.extend(['<circle cx="82" cy="135" r="5" fill="#fff3bd" stroke="#704c29"/>',
                '<text x="61" y="155" font-size="11">spawn</text>', '</g>'])
    for i, (zone, name, position, _) in enumerate(zones):
        x, z = map(round, point(position))
        svg.append(f'<text x="670" y="{112+i*40}" font-size="16" font-weight="bold">{zone} — {escape(name)}</text>')
        svg.append(f'<text x="670" y="{129+i*40}" font-size="12">Center {x-300}, {z-250}</text>')
    svg.extend(['<text x="670" y="460" font-size="13">Sand: curved circulation, 16–24 studs</text>',
                '<text x="670" y="485" font-size="13">Dashed: perimeter / future escape anchors</text>',
                '<text x="670" y="510" font-size="13">Ground: 600 × 500 studs; north at top</text>',
                '<text x="670" y="550" font-size="13">R1 review required before R2–R5.</text>',
                '</g></svg>'])
    return "\n".join(svg) + "\n"


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    path = ROOT / "docs/R1_LAYOUT.svg"
    expected = generate()
    if args.check:
        if not path.exists() or path.read_text() != expected:
            raise SystemExit("Layout diagram is stale: run python3 tools/generate_layout_diagram.py")
        print("PASS: layout schematic matches zone/route configuration")
    else:
        path.write_text(expected)
        print("Generated docs/R1_LAYOUT.svg (planning diagram, not Studio capture)")
