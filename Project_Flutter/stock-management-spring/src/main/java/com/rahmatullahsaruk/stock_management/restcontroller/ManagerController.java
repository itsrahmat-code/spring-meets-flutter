package com.rahmatullahsaruk.stock_management.restcontroller;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.rahmatullahsaruk.stock_management.entity.Manager;
import com.rahmatullahsaruk.stock_management.entity.User;
import com.rahmatullahsaruk.stock_management.repository.UserRepo;
import com.rahmatullahsaruk.stock_management.service.AuthService;
import com.rahmatullahsaruk.stock_management.service.ManagerService;
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
    @RequestMapping("/api/manager")
    @JsonIgnoreProperties
    public class ManagerController {

        @Autowired
        private UserRepo userRepo;

        @Autowired
        private AuthService authService;

        @Autowired
        private ManagerService managerService;

        private final ObjectMapper objectMapper = new ObjectMapper();

        // Manager Registration
        @PostMapping("/reg")
        public ResponseEntity<Map<String, String>> saveManager(
                @RequestPart("user") String userJson,
                @RequestPart("manager") String managerJson,
                @RequestPart(value = "photo", required = false) MultipartFile file
        ) throws JsonProcessingException {

            Map<String, String> response = new HashMap<>();

            try {
                // Deserialize JSON strings to Java objects
                User user = objectMapper.readValue(userJson, User.class);
                Manager roleManager = objectMapper.readValue(managerJson, Manager.class);

                // Call service to register manager
                authService.registerManager(user, file, roleManager);

                response.put("message", "Manager saved successfully");
                return ResponseEntity.ok(response);

            } catch (AuthenticationException authEx) {
                response.put("message", "Authentication failed: " + authEx.getMessage());
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(response);

            } catch (JsonProcessingException jsonEx) {
                response.put("message", "Invalid input data format: " + jsonEx.getMessage());
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);

            } catch (Exception e) {
                e.printStackTrace();
                response.put("message", "Manager save failed: " + e.getMessage());
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
            }
        }

        @GetMapping("/profile")
        public ResponseEntity<?> getProfile(Authentication authentication) {
            System.out.println("Authenticated User: " + authentication.getName());
            System.out.println("Authorities: " + authentication.getAuthorities());

            String email = authentication.getName();
            Optional<User> user = userRepo.findByEmail(email);

            Manager manager = managerService.getProfileByUserId(user.get().getId());
            return ResponseEntity.ok(manager);
        }
    }

