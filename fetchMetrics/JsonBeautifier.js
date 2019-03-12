const fs = require('fs');

const fileRead = fs.readFileSync('./metricsForProject.json');
const json = JSON.parse(fileRead);

const script = () => {
	const output = {};

	Object.keys(json).forEach(projectKey => {
		const project = json[projectKey]
		Object.values(project).forEach(metric => {
			if(metric.datatable.length > 0){
				if(!output[projectKey]){
					output[projectKey] = {};
				};
				output[projectKey][metric.id] = metric;
			};
		});
	});

	fs.writeFile("./beautifiedMetrics.json", JSON.stringify(output), function(err) {
	    if(err) {
	        return console.log(err);
	    }

	    console.log("The file was saved!");
	}); 
}

script();