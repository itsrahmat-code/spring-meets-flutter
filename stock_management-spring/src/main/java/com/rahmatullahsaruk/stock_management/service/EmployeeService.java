package com.rahmatullahsaruk.stock_management.service;

import com.rahmatullahsaruk.stock_management.entity.Employee;
import com.rahmatullahsaruk.stock_management.repository.EmployeeRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.*;
import java.util.List;
import java.util.UUID;

    @Service
    public class EmployeeService {

        @Autowired
        private EmployeeRepo employeeRepo;

        @Value("${image.upload.dir}")
        private String uploadDir;

        public List<Employee> getAllEmployees() {
            return employeeRepo.findAll();
        }

        public Employee getEmployeeById(Long id) {
            return employeeRepo.findById(id).orElse(null);
        }

        public Employee createEmployee(Employee employee, MultipartFile file) {
            if (file != null && !file.isEmpty()) {
                String fileName = saveImage(file, employee);
                employee.setPhoto(fileName);
            }
            return employeeRepo.save(employee);
        }

        public Employee updateEmployee(Long id, Employee updatedEmployee) {
            return employeeRepo.findById(id).map(existing -> {
                existing.setName(updatedEmployee.getName());
                existing.setEmail(updatedEmployee.getEmail());
                existing.setPhone(updatedEmployee.getPhone());
                existing.setAddress(updatedEmployee.getAddress());
                existing.setGender(updatedEmployee.getGender());
                existing.setDesignation(updatedEmployee.getDesignation());
                existing.setSalary(updatedEmployee.getSalary());
                return employeeRepo.save(existing);
            }).orElse(null);
        }

        public void deleteEmployee(Long id) {
            employeeRepo.deleteById(id);
        }

        public String saveImage(MultipartFile file, Employee employee) {
            // Ensure the upload directory is absolute and exists
            Path uploadPath = Paths.get(uploadDir, "employee");
            try {
                // Create the directory if it doesn't exist
                Files.createDirectories(uploadPath);
            } catch (IOException e) {
                throw new RuntimeException("Could not create upload directory: " + uploadPath, e);
            }

            // Extract the file extension
            String originalFilename = file.getOriginalFilename();
            String extension = "";
            if (originalFilename != null && originalFilename.contains(".")) {
                extension = originalFilename.substring(originalFilename.lastIndexOf('.')).toLowerCase();
            }

            // Sanitize the employee name to avoid invalid characters in filenames
            String safeEmployeeName = employee.getName().trim().replaceAll("[^a-zA-Z0-9_-]", "_");

            // Create a unique file name with employee name and UUID
            String fileName = safeEmployeeName + "_" + UUID.randomUUID() + extension;

            try {
                // Save the file to the directory
                Path filePath = uploadPath.resolve(fileName);
                Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);
            } catch (IOException e) {
                throw new RuntimeException("Could not save image file: " + fileName, e);
            }

            // Return the filename (you can also return the full URL or relative path if needed)
            return fileName;
        }
    }
