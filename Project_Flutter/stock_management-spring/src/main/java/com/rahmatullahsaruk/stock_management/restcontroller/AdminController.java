package com.rahmatullahsaruk.stock_management.restcontroller;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.rahmatullahsaruk.stock_management.entity.Admin;
import com.rahmatullahsaruk.stock_management.entity.User;
import com.rahmatullahsaruk.stock_management.repository.UserRepo;
import com.rahmatullahsaruk.stock_management.service.AdminService;
import com.rahmatullahsaruk.stock_management.service.AuthService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.security.sasl.AuthenticationException;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

    @RestController
    @RequestMapping("/api/admin")
    @JsonIgnoreProperties
    public class AdminController {


        @Autowired
        private UserRepo userRepo;
        @Autowired
        private AuthService authService;
        @Autowired
        private AdminService adminService;

        private final ObjectMapper objectMapper = new ObjectMapper();



        //  Admin Registration

        @PostMapping("/reg")
        public ResponseEntity<Map<String, String>> saveAdmin(
                @RequestPart("user") String userJson,
                @RequestPart("admin") String adminJson,
                @RequestPart(value = "photo", required = false) MultipartFile file
        ) throws JsonProcessingException {

            Map<String, String> response = new HashMap<>();

            try {
                // Deserialize JSON strings to Java objects
                User user = objectMapper.readValue(userJson, User.class);
                Admin admin = objectMapper.readValue(adminJson,Admin.class);

                // Call service to register super admin
                authService.registerAdmin(user, file,admin);

                response.put("message", " Admin saved successfully");
                return ResponseEntity.ok(response);

            } catch (AuthenticationException authEx) {
                // If there's an authentication issue, return 401 Unauthorized
                response.put("message", "Authentication failed: " + authEx.getMessage());
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(response);

            } catch (JsonProcessingException jsonEx) {
                // Bad JSON format
                response.put("message", "Invalid input data format: " + jsonEx.getMessage());
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);

            } catch (Exception e) {
                // Unexpected server error
                e.printStackTrace(); // Log full stack trace to console or log file
                response.put("message", "Admin save failed: " + e.getMessage());
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
            }
        }

        @GetMapping("/profile")
        public ResponseEntity<?> getProfile(Authentication authentication) {
            System.out.println("Authenticated User: " + authentication.getName());
            System.out.println("Authorities: " + authentication.getAuthorities());
            String email = authentication.getName();
            Optional<User> user =userRepo.findByEmail(email);
            Admin admin = adminService.getProfileByUserId(user.get().getId());
            return ResponseEntity.ok(admin);

        }


    }

