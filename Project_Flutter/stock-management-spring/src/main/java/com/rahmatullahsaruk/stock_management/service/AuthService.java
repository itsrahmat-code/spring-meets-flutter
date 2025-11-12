package com.rahmatullahsaruk.stock_management.service;

import com.rahmatullahsaruk.stock_management.dto.AuthDTO;
import com.rahmatullahsaruk.stock_management.dto.UserDTO;
import com.rahmatullahsaruk.stock_management.entity.*;
import com.rahmatullahsaruk.stock_management.jwt.JwtService;
import com.rahmatullahsaruk.stock_management.repository.TokenRepo;
import com.rahmatullahsaruk.stock_management.repository.UserRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Lazy;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.UUID;

@Service
public class AuthService {

    @Autowired
    private PasswordEncoder passwordEncoder;
    @Autowired
    private UserRepo userRepo;
    @Autowired
    private TokenRepo tokenRepo;

    @Autowired
    private JwtService jwtService;

    @Autowired
    private AdminService adminService;
    @Autowired
    private ManagerService managerService;
    @Autowired
    private CashierService cashierService;

    @Autowired
    @Lazy
    private AuthenticationManager authenticationManager;

    @Value("src/main/resources/static/images")
    private String uploadDir;

    public void saveOrUpdate(User user, MultipartFile imageFile) {

        if (imageFile != null && !imageFile.isEmpty()) {
            String filename = saveImage(imageFile, user);
            user.setPhoto(filename);
        }

        user.setRole(Role.ADMIN);
        userRepo.save(user);
        // (Email sending removed)
    }

    public List<User> findAllUsers() {
        return userRepo.findAll();
    }

    public List<UserDTO> getAllUsersDTOS() {
        return userRepo.findAll().stream().map(user -> {
            UserDTO dto = new UserDTO();

            dto.setId(user.getId());
            dto.setEmail(user.getEmail());
            dto.setName(user.getName());
            dto.setPhoto(user.getPhoto());
            dto.setPhone(user.getPhone());

            return dto;
        }).toList();
    }

    public User findById(int id) {
        return userRepo.findById(id).get();
    }

    public void delete(User user) {
        userRepo.delete(user);
    }

    // ---- Admin ----
    public String saveImageForAdmin(MultipartFile file, Admin admin) {
        Path uploadPath = Paths.get(uploadDir + "/admin");
        if (!Files.exists(uploadPath)) {
            try {
                Files.createDirectory(uploadPath);
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
        }

        String adminName = admin.getName();
        String fileName = adminName.trim().replaceAll("\\s+", "_");
        String savedFileName = fileName + "_" + UUID.randomUUID();

        try {
            Path filePath = uploadPath.resolve(savedFileName);
            Files.copy(file.getInputStream(), filePath);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        return savedFileName;
    }

    public void registerAdmin(User user, MultipartFile imageFile, Admin adminData) throws IOException {
        if (imageFile != null && !imageFile.isEmpty()) {
            String fileName = saveImage(imageFile, user);
            String adminImage = saveImageForAdmin(imageFile, adminData);
            adminData.setPhoto(adminImage);
            user.setPhoto(fileName);
        }

        user.setPassword(passwordEncoder.encode(user.getPassword()));
        user.setRole(Role.ADMIN);
        user.setActive(true);

        User savedUser = userRepo.save(user);

        adminData.setUser(savedUser);
        adminService.save(adminData);

        String jwt = jwtService.generateToken(savedUser);
        saveUserToken(jwt, savedUser);
        // (Email sending removed)
    }

    // ---- Common user image ----
    public String saveImage(MultipartFile file, User user) {
        Path uploadPath = Paths.get(uploadDir + "/users");
        if (!Files.exists(uploadPath)) {
            try {
                Files.createDirectory(uploadPath);
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
        }

        String fileName = user.getName() + "_" + UUID.randomUUID();

        try {
            Path filePath = uploadPath.resolve(fileName);
            Files.copy(file.getInputStream(), filePath);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        return fileName;
    }

    // ---- Manager ----
    public String saveImageForManager(MultipartFile file, Manager manager) {
        Path uploadPath = Paths.get(uploadDir + "/roleManager");
        if (!Files.exists(uploadPath)) {
            try {
                Files.createDirectory(uploadPath);
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
        }

        String managerName = manager.getName();
        String fileName = managerName.trim().replaceAll("\\s+", "_");
        String savedFileName = fileName + "_" + UUID.randomUUID();

        try {
            Path filePath = uploadPath.resolve(savedFileName);
            Files.copy(file.getInputStream(), filePath);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        return savedFileName;
    }

    public void registerManager(User user, MultipartFile imageFile, Manager managerdata) throws IOException {
        if (imageFile != null && !imageFile.isEmpty()) {
            String filename = saveImage(imageFile, user);
            String managerImage = saveImageForManager(imageFile, managerdata);
            managerdata.setPhoto(managerImage);
            user.setPhoto(filename);
        }

        user.setPassword(passwordEncoder.encode(user.getPassword()));
        user.setRole(Role.MANAGER);
        user.setActive(false);

        User savedUser = userRepo.save(user);

        managerdata.setUser(savedUser);
        managerService.save(managerdata);

        String jwt = jwtService.generateToken(savedUser);
        saveUserToken(jwt, savedUser);
        // (Email sending removed)
    }

    // ---- Cashier ----
    public String saveImageForCashier(MultipartFile file, Cashier cashier) {
        Path uploadPath = Paths.get(uploadDir + "/roleCashier");
        if (!Files.exists(uploadPath)) {
            try {
                Files.createDirectory(uploadPath);
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
        }

        String cashierName = cashier.getName();
        String fileName = cashierName.trim().replaceAll("\\s+", "_");
        String savedFileName = fileName + "_" + UUID.randomUUID();

        try {
            Path filePath = uploadPath.resolve(savedFileName);
            Files.copy(file.getInputStream(), filePath);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        return savedFileName;
    }

    public void registerCashier(User user, MultipartFile imageFile, Cashier cashierData) throws IOException {
        if (imageFile != null && !imageFile.isEmpty()) {
            String filename = saveImage(imageFile, user);
            String cashierImage = saveImageForCashier(imageFile, cashierData);
            cashierData.setPhoto(cashierImage);
            user.setPhoto(filename);
        }

        user.setPassword(passwordEncoder.encode(user.getPassword()));
        user.setRole(Role.CASHIER);
        user.setActive(false);

        User savedUser = userRepo.save(user);

        cashierData.setUser(savedUser);
        cashierService.save(cashierData);

        String jwt = jwtService.generateToken(savedUser);
        saveUserToken(jwt, savedUser);

        // (Email sending removed)
    }

    private void saveUserToken(String jwt, User user) {
        Token token = new Token();
        token.setToken(jwt);
        token.setLogout(false);
        token.setUser(user);
        tokenRepo.save(token);
    }

    private void removeAllTokenByUser(User user) {
        List<Token> validTokens = tokenRepo.findAllTokenByUser(user.getId());
        if (validTokens.isEmpty()) return;

        validTokens.forEach(t -> t.setLogout(true));
        tokenRepo.saveAll(validTokens);
    }

    // ---- Login ----
    public AuthDTO authenticate(User request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.getUsername(),
                        request.getPassword()
                )
        );

        User user = userRepo.findByEmail(request.getEmail())
                .orElseThrow(() -> new UsernameNotFoundException("User not found"));

        if (!user.isActive()) {
            throw new RuntimeException("Account is not activated.");
        }

        String jwt = jwtService.generateToken(user);

        removeAllTokenByUser(user);
        saveUserToken(jwt, user);

        return new AuthDTO(jwt, "User Login Successful");
    }

    public String activeUser(int id) {
        User user = userRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("User not Found with this ID " + id));

        user.setActive(true);
        userRepo.save(user);
        return "User Activated Successfully!";
    }
}
