# FetchMetrics - Request data from a Scava Api to json

## Setup
* Requires node.js

Execute `npm install` at the root of the project to install node dependencies.

## Usage
* fetchMetrics.js fetch the data from a Scava Api.
* JsonBeautifier.js enhance the json of the above script by filtering metrics empty data.

Start the script that fetch the data with `node fetchMetrics.js` then execute `node JsonBeautifier.js` to filter the data.
The final output is the file `beautifiedMetrics.json`.