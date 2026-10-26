#Requires -Version 7.0
using namespace System.Collections.Generic

# Single line comment
<#
  Multi line
  comment
#>

<#
.SYNOPSIS
    Comment-based help.
.PARAMETER Name
    The name to greet.
#>

# Variables and literals
$int = 42
$float = 3.14
$exp = 1.5e3
$hex = 0xFF
$size = 10MB
$yes, $no, $nothing = $true, $false, $null
${variable with spaces} = 'value'
$env:PATH
$script:counter = 0
$global:config = @{}

# Strings
$single = 'single $notExpanded'
$double = "double $int and $($int + 1) with `"escapes`" `n`t"
$hereDouble = @"
Here-string with $int
"@
$hereSingle = @'
Literal here-string $int
'@

# Collections
$array = @(1, 2, 3)
$range = 1..10
$hash = @{ Name = 'Ann'; Age = 30 }
$ordered = [ordered]@{ First = 1; Second = 2 }
$list = [List[int]]::new()

# Types and casts
[int]$typed = '5'
[string[]]$names = 'a', 'b'
[datetime]::Now
[System.IO.Path]::Combine('a', 'b')
[Math]::PI

# Operators
$sum = 1 + 2 - 3 * 4 / 5 % 6
$cmp = 1 -eq 2 -or 1 -ne 2 -and 1 -lt 2 -and 1 -le 2 -and 1 -gt 2 -and 1 -ge 2
$text = 'abc' -like 'a*' -and 'abc' -match '^a' -and 'abc' -notlike 'z*'
$replaced = 'hello' -replace 'l', 'L'
$parts = 'a,b,c' -split ','
$joined = $parts -join ';'
$contains = $array -contains 2 -and 2 -in $array
$isString = $text -is [string]
$not = -not $true
$bang = !$false
$counter++
$counter += 5
$value = $null ?? 'default'
$ternary = $true ? 'yes' : 'no'

# Functions
function Get-Greeting {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [int]$Times = 1,

        [switch]$Loud
    )

    begin { $results = @() }
    process {
        $greeting = "Hello, $Name!"
        if ($Loud) { $greeting = $greeting.ToUpper() }
        $results += $greeting
    }
    end { return $results }
}

filter Select-Even { if ($_ % 2 -eq 0) { $_ } }

$scriptBlock = { param($x) $x * 2 }
& $scriptBlock 21

# Classes and enums
enum Color {
    Red
    Green = 2
}

class Animal {
    [string]$Name
    static [int]$Count = 0
    hidden [bool]$Secret

    Animal([string]$name) {
        $this.Name = $name
        [Animal]::Count++
    }

    [string] Speak() {
        return "$($this.Name) makes a sound"
    }
}

class Dog : Animal {
    Dog([string]$name) : base($name) {}

    [string] Speak() { return 'Woof' }
}

# Control flow
if ($int -gt 40) {
    Write-Host 'big'
} elseif ($int -eq 40) {
    Write-Host 'exact'
} else {
    Write-Host 'small'
}

switch -Regex ($text) {
    '^a' { 'starts with a'; break }
    default { 'other' }
}

foreach ($item in $array) {
    if ($item -eq 2) { continue }
    Write-Output $item
}

for ($i = 0; $i -lt 3; $i++) { $i }
while ($counter -gt 0) { $counter-- }
do { $counter++ } until ($counter -ge 3)

# Pipelines and cmdlets
Get-ChildItem -Path . -Filter *.ps1 -Recurse |
    Where-Object { $_.Length -gt 1KB } |
    Sort-Object -Property Length -Descending |
    Select-Object -First 5 Name, Length |
    ForEach-Object { "$($_.Name): $($_.Length)" }

Get-Process | Where-Object CPU -gt 100 | Stop-Process -WhatIf
$params = @{ Path = '.'; Recurse = $true }
Get-ChildItem @params

# Error handling
try {
    throw [System.InvalidOperationException]::new('Boom')
} catch [System.InvalidOperationException] {
    Write-Error $_.Exception.Message
} finally {
    Write-Verbose 'done'
}

trap { Write-Warning $_; continue }

# Redirection and splatting
Get-Content 'missing.txt' 2>&1 > $null
Write-Output 'log' >> log.txt
$output = & git status 2>$null
Start-Process -FilePath 'notepad.exe' -ArgumentList 'file.txt' -Wait

# Attributes and modules
function Show-Message {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
    param([string]$Message)
    Write-Host $Message -ForegroundColor Green
}

Import-Module -Name Pester -MinimumVersion 5.0
Export-ModuleMember -Function Get-Greeting
