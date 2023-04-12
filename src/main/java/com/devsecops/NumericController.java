package com.devsecops;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;
import java.io.InputStream;
import java.io.BufferedReader;
import java.io.InputStreamReader;


@RestController
public class NumericController {

	private final Logger logger = LoggerFactory.getLogger(getClass());
	private static final String baseURL = "http://node-service:5000/plusone";

	RestTemplate restTemplate = new RestTemplate();
	@Autowired
    private ResourceLoader resourceLoader;

	@RestController
	public class compare {

		@GetMapping("/")
		// public String welcome() {
		// 	return "Kubernetes DevSecOps";
		// }
        // public ResponseEntity<String> welcome() throws IOException {
        //     HttpHeaders headers = new HttpHeaders();
        //     headers.setContentType(MediaType.TEXT_HTML);
        //     Path path = Paths.get("./index.html");
        //     byte[] data = Files.readAllBytes(path);
        //     String html = new String(data);
        //     ;
        // }

		public ResponseEntity<String> welcome() {
			try {
				Resource resource = resourceLoader.getResource("classpath:static/test.html");
				InputStream inputStream = resource.getInputStream();
				BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream));
				String line;
				StringBuilder builder = new StringBuilder();
				while ((line = reader.readLine()) != null) {
					builder.append(line);
				}
				return ResponseEntity.ok().body(builder.toString());
			} catch (IOException e) {
				logger.error("Failed to read index.html file.", e);
				return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Failed to read index.html file.");
			}
		}

		@GetMapping("/compare/{value}")
		public String compareToFifty(@PathVariable int value) {
			String message = "Could not determine comparison";
			if (value > 50) {
				message = "Greater than 50";
			} else {
				message = "Smaller than or equal to 50";
			}
			return message;
		}

		@GetMapping("/increment/{value}")
		public int increment(@PathVariable int value) {
			ResponseEntity<String> responseEntity = restTemplate.getForEntity(baseURL + '/' + value, String.class);
			String response = responseEntity.getBody();
			logger.info("Value Received in Request - " + value);
			logger.info("Node Service Response - " + response);
			return Integer.parseInt(response);
		}
	}

}
