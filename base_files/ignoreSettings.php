<?php
/*
 * Script to ignore items when syncing config in Backdrop
 *
 * The items in the two system.core.json files should be the same order
 * because sites are cloned
 *
 * I real life this script will be run byt a script in the DOCUMENT_ROOT
 */
#$rootDir = realpath($_SERVER["DOCUMENT_ROOT"]);
$rootDir = "/home/francis/FG-Docs/PhpstormProjects/ignoreSettings";
$sourceFile = $rootDir . "/config/active/system.core.json";
$targetFile = $rootDir . "/config/staging/system.core.json";
$tempFile = $rootDir . "/system.core.json";
$f = file_get_contents($sourceFile, "r");
$parts = explode("\n", $f);
# THis takes care of caching in local, Dev and Prod,
# and the site details
$patternArray = array(
    'cache',
    'preprocess_css',
    'preprocess_js',
    'site_name',
    'site_mail',
    'site_slogan'
);
$sourceItems = array();
# get the source items into the array
foreach ($parts as &$line) {
    foreach ($patternArray as &$pattern)
        if (preg_match('/\"' . $pattern . '\":/', $line)) {
            array_push($sourceItems, $line);
        }
}
# Now to write this to the temp file
$f = file_get_contents($targetFile, "r");
$tf = fopen($tempFile, "w");
$parts = explode("\n", $f);
$x = 0;
foreach ($parts as &$line) {
    foreach ($patternArray as &$pattern)
        if (preg_match($pattern, $line)) {
            $line = $sourceItems[$x];
            $x++;
        }
    fwrite($tf, $line . "\n");
}
fclose($tf);
# and overwrite the target file
rename($tempFile, $targetFile);
?>

