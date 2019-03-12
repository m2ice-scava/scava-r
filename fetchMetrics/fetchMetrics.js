const fetch = require("node-fetch");
const fs = require('fs');
const Json2csvParser = require('json2csv').Parser;

const SCAVA_URL = "http://your-scava-url.com"; // REPLACE THIS WITH YOUR SCAVA BACKEND

const main = async() => {
	const fetchMetrics = async() => {
		const projectsResponse = await fetch(`${SCAVA_URL}:8182/projects/`);
		const projects = await projectsResponse.json();

		const metricsResponse = await fetch(`${SCAVA_URL}:8182/metrics/`);
		const metrics = await metricsResponse.json();

		const projectsWithMetrics = {};

		await Promise.all(projects.map(async(project) => {
			await Promise.all(metrics.map(async(metric) => {
				try{
					const metricForProjectResponse = await fetch(`${SCAVA_URL}:8182/projects/p/${project.shortName}/m/${metric.id}`);
					const metricForProject = await metricForProjectResponse.json();

					if(!projectsWithMetrics[project.shortName]){
						console.log('projectsWithMetrics dont exists', project.shortName);
						projectsWithMetrics[project.shortName] = {};
					}
					console.log(project.shortName + ' has value ' + metric.id);
					projectsWithMetrics[project.shortName][metric.id] = metricForProject;
				} catch(e){
					console.log(project.shortName + ' do not have value ' + metric.id);
				}
			}));
		}));
		return projectsWithMetrics;
	}


	const metricsForProject = await fetchMetrics();
	fs.writeFile("./metricsForProject.json", JSON.stringify(metricsForProject), function(err) {
		    if(err) {
		        return console.log(err);
		    }

		    console.log("The file was saved!");
		});
}

main();