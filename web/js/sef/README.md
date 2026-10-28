
# Wie kompiliert man ein XSL-Stylesheet zu `sef.json`?



## Schritt 1: Node.js installieren



Falls Node.js noch nicht installiert ist, lade die LTS-Version für Windows x64 herunter und führe die .msi-Datei aus:



[Node.js herunterladen](https://nodejs.org/)



Öffne danach die Windows-Eingabeaufforderung (`cmd`) und prüfe:



```cmd
node --version
npm --version
```



Wenn beide Befehle eine Versionsnummer ausgeben, kannst du fortfahren.



## Schritt 2: In deinen Ordner wechseln



Gib in der Eingabeaufforderung (`cmd`) Folgendes ein:



```cmd
cd C:\pathToFolder\SaxonJS_XSLCompiler
```



Ersetze den Pfad durch den Ordner, in dem sich dein XSL-Stylesheet befindet.



## Schritt 3: Den Compiler installieren



Installiere SaxonJS und das Kommandozeilenwerkzeug `xslt3` direkt in diesem Ordner:



```cmd
npm install saxon-js xslt3
```



## Schritt 4: Stylesheet kompilieren



Angenommen, deine XSL-Datei heißt `zuRechtKwic2Html.xsl`. Führe diesen Befehl aus:



```cmd

npx xslt3 -xsl:zuRechtKwic2Html.xsl -export:zuRechtKwic2Html.sef.json -nogo "-ns:##html5"

```



Die Optionen bedeuten:



- `-xsl:zuRechtKwic2Html.xsl`: Gibt das vorhandene Stylesheet an.

- `-export:zuRechtKwic2Html.sef.json`: Legt den Namen der erzeugten Datei fest.

- `-nogo`: Kompiliert nur, ohne die Transformation auszuführen.

- `-ns:##html5`: Aktiviert die HTML5-Namespace-Behandlung, was bei HTML-Ausgabe hilfreich sein kann.



Nach erfolgreicher Kompilierung sollte die Datei `zuRechtKwic2Html.sef.json` im aktuellen Ordner vorhanden sein.



