# draw.io XML reference

Condensed from the official draw.io MCP project's reference. For anything not covered here (layers,
tags, placeholders, dark mode, table layouts, routing passes), read
https://github.com/jgraph/drawio-mcp/blob/main/shared/xml-reference.md

## Contents
- File skeleton
- Layout rules
- Common shapes
- UML class
- UML relationships
- Containers
- Well-formedness rules

## File skeleton

```xml
<mxfile host="app.diagrams.net">
  <diagram id="name" name="Name">
    <mxGraphModel dx="1000" dy="600" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="1100" pageHeight="700" math="0" shadow="0">
      <root>
        <mxCell id="0"/>
        <mxCell id="1" parent="0"/>
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>
```

Cells `0` and `1` always exist. Put every vertex and edge inside `<root>` with `parent="1"` (or a container id).

## Layout rules

Place nodes on a grid and do not hand-route edges.

- Column x = `col * 180 + 40`; row y = `row * 120 + 40`.
- Sizes: rectangle 140x60, diamond 140x80, cylinder 100x70, small circle 60x60.
- One node per grid cell. Declare `source` and `target` on edges; no waypoints, no exit/entry overrides.
- Do not re-check coordinates after placing a node.

## Common shapes

```xml
<mxCell id="n1" value="Web API" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#dae8fc;strokeColor=#6c8ebf;" vertex="1" parent="1">
  <mxGeometry x="40" y="40" width="140" height="60" as="geometry"/>
</mxCell>
<mxCell id="n2" value="PostgreSQL" style="shape=cylinder3;whiteSpace=wrap;html=1;fillColor=#d5e8d4;strokeColor=#82b366;" vertex="1" parent="1">
  <mxGeometry x="220" y="40" width="100" height="70" as="geometry"/>
</mxCell>
<mxCell id="e1" value="SQL" style="edgeStyle=orthogonalEdgeStyle;rounded=1;html=1;" edge="1" source="n1" target="n2" parent="1">
  <mxGeometry relative="1" as="geometry"/>
</mxCell>
```

- Decision: `rhombus;whiteSpace=wrap;html=1;`. Actor or external system: `rounded=1;dashed=1;`.
- Always include `html=1`. Line break in a label: `&lt;br&gt;` (needs `html=1`) or `&#xa;`; never `\n`.
- Edge style per diagram type: architecture and flows `edgeStyle=orthogonalEdgeStyle`; UML class straight
  (no `edgeStyle`); ERD `edgeStyle=entityRelationEdgeStyle`.
- Colors: blue `#dae8fc/#6c8ebf`, green `#d5e8d4/#82b366`, yellow `#fff2cc/#d6b656`, red `#f8cecc/#b85450`,
  grey `#f5f5f5/#666666` (fill/stroke).

## UML class

A class is a swimlane container with child text cells. Children use coordinates relative to the class;
the class height is header (26) plus the child heights.

```xml
<mxCell id="c1" value="Order" style="swimlane;fontStyle=1;align=center;verticalAlign=top;childLayout=stackLayout;horizontal=1;startSize=26;horizontalStack=0;resizeParent=1;resizeParentMax=0;resizeLast=0;collapsible=1;marginBottom=0;html=1;" vertex="1" parent="1">
  <mxGeometry x="40" y="40" width="180" height="86" as="geometry"/>
</mxCell>
<mxCell id="c1a" value="+ Id: Guid&#xa;+ Total: decimal" style="text;strokeColor=none;fillColor=none;align=left;verticalAlign=top;spacingLeft=4;spacingRight=4;overflow=hidden;rotatable=0;whiteSpace=wrap;html=1;" vertex="1" parent="c1">
  <mxGeometry y="26" width="180" height="34" as="geometry"/>
</mxCell>
<mxCell id="c1s" value="" style="line;strokeWidth=1;fillColor=none;align=left;verticalAlign=middle;spacingTop=-1;spacingLeft=3;spacingRight=3;rotatable=0;labelPosition=right;points=[];portConstraint=eastwest;strokeColor=inherit;" vertex="1" parent="c1">
  <mxGeometry y="60" width="180" height="8" as="geometry"/>
</mxCell>
<mxCell id="c1m" value="+ Submit(): void" style="text;strokeColor=none;fillColor=none;align=left;verticalAlign=top;spacingLeft=4;spacingRight=4;overflow=hidden;rotatable=0;whiteSpace=wrap;html=1;" vertex="1" parent="c1">
  <mxGeometry y="68" width="180" height="18" as="geometry"/>
</mxCell>
```

Use 17-18 px per member line. Interfaces: prefix the title with `&lt;&lt;interface&gt;&gt;&#xa;`.

## UML relationships

Set `source` to the child, part, or dependent; `target` to the parent, whole, or dependency. The
arrowhead is drawn at the target.

| Relationship | Edge style |
|--------------|------------|
| Inheritance | `endArrow=block;endSize=16;endFill=0;html=1;` |
| Realization (implements) | `endArrow=block;endSize=16;endFill=0;dashed=1;html=1;` |
| Association | `endArrow=open;endSize=12;html=1;` |
| Dependency | `endArrow=open;endSize=12;dashed=1;html=1;` |
| Aggregation | `endArrow=diamondThin;endSize=16;endFill=0;html=1;` |
| Composition | `endArrow=diamondThin;endSize=16;endFill=1;html=1;` |

Multiplicity or role: put it in the edge `value` (`1..*`, `owns`).

## Containers

Use a swimlane for a titled group (layer, bounded context, VPC):
`swimlane;startSize=30;fillColor=#f5f5f5;strokeColor=#666666;html=1;`. Children set `parent="<container id>"`
with coordinates relative to the container. Add `container=1;pointerEvents=0;` to any non-swimlane shape
used as a container.

File each edge under the innermost container that holds both endpoints; use `parent="1"` when one
endpoint is outside all containers. Edges to children may cross the container border.

## Well-formedness rules

- No XML comments (`<!-- -->`).
- Every edge has a child `<mxGeometry relative="1" as="geometry"/>`; never a self-closing edge cell.
- Every `id` is unique; every `parent`, `source`, and `target` refers to an existing id.
- Escape `&amp;`, `&lt;`, `&gt;`, `&quot;` in attribute values.
- Save as uncompressed XML so it diffs and validates.
