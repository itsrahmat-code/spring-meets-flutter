package com.rahmatullahsaruk.stock_management.service;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.lang.reflect.Method;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

    @Service
    public class PhotoService {

        @Value("${image.upload.dir}")
        private String uploadDir;


        public <T> String savePhoto(T entity, String subDirectory, MultipartFile file) {
            Path uploadPath = Paths.get(uploadDir + subDirectory);
            if (!Files.exists(uploadPath)) {
                try {
                    Files.createDirectories(uploadPath);
                } catch (IOException e) {
                    throw new RuntimeException("Could not create upload directory", e);
                }
            }

            // Get the name using reflection
            String name;
            try {
                Method getNameMethod = entity.getClass().getMethod("getName");
                name = (String) ((Method) getNameMethod).invoke(entity);
            } catch (Exception e) {
                throw new RuntimeException("Failed to get name from entity", e);
            }

            // Get original file extension
            String originalFilename = file.getOriginalFilename();
            String extension = "";
            if (originalFilename != null && originalFilename.contains(".")) {
                extension = originalFilename.substring(originalFilename.lastIndexOf("."));
            }

            // Build unique file name
            String fileName = name + "_" + UUID.randomUUID() + extension;

            // Save the file
            try {
                Path filePath = uploadPath.resolve(fileName);
                Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);
            } catch (IOException e) {
                throw new RuntimeException("Failed to save file", e);
            }

            return fileName;
        }

        public <T> List<String> savePhotos(T entity, String subDirectory, MultipartFile[] files) {
            List<String> savedFileNames = new ArrayList<>();

            Path uploadPath = Paths.get(uploadDir + subDirectory);
            if (!Files.exists(uploadPath)) {
                try {
                    Files.createDirectories(uploadPath);
                } catch (IOException e) {
                    throw new RuntimeException("Could not create upload directory", e);
                }
            }

            String name;
            try {
                Method getNameMethod = entity.getClass().getMethod("getName");
                name = (String) getNameMethod.invoke(entity);
            } catch (Exception e) {
                throw new RuntimeException("Failed to get name from entity", e);
            }

            for (MultipartFile file : files) {
                String originalFilename = file.getOriginalFilename();
                String extension = "";
                if (originalFilename != null && originalFilename.contains(".")) {
                    extension = originalFilename.substring(originalFilename.lastIndexOf("."));
                }

                String fileName = name + "_" + UUID.randomUUID() + extension;

                try {
                    Path filePath = uploadPath.resolve(fileName);
                    Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);
                    savedFileNames.add(fileName);
                } catch (IOException e) {
                    throw new RuntimeException("Failed to save file", e);
                }
            }

            return savedFileNames;
        }

        public void deletePhoto(String subDirectory, String fileName) {
            Path filePath = Paths.get(uploadDir + subDirectory + "/" + fileName);
            try {
                Files.deleteIfExists(filePath);
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
        }

    }

