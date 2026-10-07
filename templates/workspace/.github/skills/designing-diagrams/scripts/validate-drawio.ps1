<#
.SYNOPSIS
  Validates .drawio files: well-formed XML, unique ids, existing parent/source/target, geometry on cells.
.EXAMPLE
  ./validate-drawio.ps1 docs/diagrams/system.drawio
#>
param(
    [Parameter(Mandatory, Position = 0, ValueFromRemainingArguments)]
    [string[]]$Path
)

$failed = $false

foreach ($file in $Path) {
    $errors = [System.Collections.Generic.List[string]]::new()
    $text = Get-Content -LiteralPath $file -Raw -Encoding UTF8
    $doc = $null

    if ($text.Contains('<!--')) { $errors.Add('XML comments are not allowed') }
    try { $doc = [xml]$text } catch { $errors.Add("not well-formed XML: $($_.Exception.Message)") }

    if ($doc) {
        $models = @($doc.SelectNodes('//mxGraphModel'))
        if ($models.Count -eq 0) {
            $errors.Add('no <mxGraphModel> found (compressed diagram? save as uncompressed XML)')
        }

        foreach ($model in $models) {
            # <object>/<UserObject> wrappers carry the id; the mxCell inside carries the rest.
            $cells = @(foreach ($node in $model.SelectNodes('root/*')) {
                    if ($node.LocalName -eq 'mxCell') {
                        [pscustomobject]@{ Id = $node.GetAttribute('id'); Cell = $node }
                    }
                    elseif ($node.LocalName -in 'object', 'UserObject') {
                        $inner = $node.SelectSingleNode('mxCell')
                        if ($inner) { [pscustomobject]@{ Id = $node.GetAttribute('id'); Cell = $inner } }
                    }
                })

            $known = [System.Collections.Generic.HashSet[string]]::new([string[]]@($cells.Id))
            foreach ($dup in ($cells | Group-Object Id | Where-Object Count -gt 1)) {
                $errors.Add("id=$($dup.Name): duplicate id")
            }
            if (-not $known.Contains('0')) { $errors.Add('missing root cell id="0"') }

            foreach ($c in $cells) {
                foreach ($attr in 'parent', 'source', 'target') {
                    $ref = $c.Cell.GetAttribute($attr)
                    if ($ref -and -not $known.Contains($ref)) {
                        $errors.Add("id=$($c.Id): $attr='$ref' does not exist")
                    }
                }
                $isShape = $c.Cell.GetAttribute('edge') -eq '1' -or $c.Cell.GetAttribute('vertex') -eq '1'
                if ($isShape -and -not $c.Cell.SelectSingleNode('mxGeometry')) {
                    $errors.Add("id=$($c.Id): missing <mxGeometry> child")
                }
            }
        }
    }

    if ($errors.Count -gt 0) {
        $failed = $true
        Write-Output "FAIL $file"
        $errors | ForEach-Object { Write-Output "  - $_" }
    }
    else {
        Write-Output "OK   $file"
    }
}

if ($failed) { exit 1 }
exit 0
