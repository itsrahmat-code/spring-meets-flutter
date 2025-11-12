package com.rahmatullahsaruk.stock_management.config;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

    @Configuration
    public class WebConfig implements WebMvcConfigurer {

        @Value("${image.upload.dir}")
        private String uploadDir;

        @Override
        public void addResourceHandlers(ResourceHandlerRegistry registry) {
            // Log the value of uploadDir
            System.out.println("Image upload directory: " + uploadDir);

            registry.addResourceHandler("/images/**")
                    .addResourceLocations("file:" + uploadDir + "/");

        }
    }

