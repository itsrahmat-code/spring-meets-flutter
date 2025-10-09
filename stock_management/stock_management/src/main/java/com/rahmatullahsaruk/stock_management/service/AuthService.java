package com.rahmatullahsaruk.stock_management.service;
import com.rahmatullahsaruk.stock_management.dto.AuthResponse;
import com.rahmatullahsaruk.stock_management.entity.Token;
import com.rahmatullahsaruk.stock_management.entity.User;
import com.rahmatullahsaruk.stock_management.jwt.JwtService;
import com.rahmatullahsaruk.stock_management.repository.IEmployeeRepository;
import com.rahmatullahsaruk.stock_management.repository.ITokenRepository;
import com.rahmatullahsaruk.stock_management.repository.IUserRepository;
import jakarta.mail.MessagingException;
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
        private IUserRepository userRepository;

        @Autowired
        private ITokenRepository tokenRepository;

        @Autowired
        private IEmployeeRepository employeeRepository;

        @Autowired
        private EmailService emailService;

        @Autowired
        private PhotoService photoService;

        @Autowired
        private CustomerService customerService;

        @Autowired
        private JwtService jwtService;

        @Autowired
        @Lazy
        private AuthenticationManager authenticationManager;


        @Value("src/main/resources/static/images")
        private String uploadDir;
        @Autowired
        private EmployeeService employeeService;


        public List<User> findAll() {
            return userRepository.findAll();
        }

        public User findById(int id) {
            return userRepository.findById(id).get();
        }

        public void delete(User user) {
            userRepository.delete(user);
        }

        private void sendActivationEmail(User user) {
            String subject = "Welcome to Our Service – Confirm Your Registration";

            String activationLink = "http://localhost:8085/api/user/active/" + user.getId();

            String mailText = "<!DOCTYPE html>"
                    + "<html>"
                    + "<head>"
                    + "<style>"
                    + "  body { font-family: Arial, sans-serif; line-height: 1.6; }"
                    + "  .container { max-width: 600px; margin: auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 10px; }"
                    + "  .header { background-color: #4CAF50; color: white; padding: 10px; text-align: center; border-radius: 10px 10px 0 0; }"
                    + "  .content { padding: 20px; }"
                    + "  .footer { font-size: 0.9em; color: #777; margin-top: 20px; text-align: center; }"
                    + "</style>"
                    + "</head>"
                    + "<body>"
                    + "  <div class='container'>"
                    + "    <div class='header'>"
                    + "      <h2>Welcome to Our Platform</h2>"
                    + "    </div>"
                    + "    <div class='content'>"
                    + "      <p>Dear " + user.getName() + ",</p>"
                    + "      <p>Thank you for registering with us. We are excited to have you on board!</p>"
                    + "      <p>Please confirm your email address to activate your account and get started.</p>"
                    + "      <p>If you have any questions or need help, feel free to reach out to our support team.</p>"
                    + "      <br>"
                    + "      <p>Best regards,<br>The Support Team</p>"
                    + "      <p>To Activate Your Account, please click the following link:</p>"
                    + "      <p><a href=\"" + activationLink + "\">Activate Account</a></p>"
                    + "    </div>"
                    + "    <div class='footer'>"
                    + "      &copy; " + java.time.Year.now() + " YourCompany. All rights reserved."
                    + "    </div>"
                    + "  </div>"
                    + "</body>"
                    + "</html>";

            try {
                emailService.sendSimpleEmail(user.getEmail(), subject, mailText);
            } catch (MessagingException e) {
                throw new RuntimeException("Failed to send activation email", e);
            }
        }


        public void registerEmployee(User user, MultipartFile file, Employee employee) {
            if(file != null && !file.isEmpty()) {
                String fileName = photoService.savePhoto(employee, "/employees",  file);
                employee.setPhoto(fileName);
                user.setPhoto(fileName);
            }

            user.setPassword(passwordEncoder.encode(user.getPassword()));
            user.setActive(false);
            User savedUser = userRepository.save(user);

            employee.setUser(savedUser);
            employeeService.save(employee);

            String jwt = jwtService.generateToken(savedUser);
            saveUserToken(jwt, savedUser);
        }


        private void saveUserToken(String jwt, User user) {
            Token token = new Token();
            token.setToken(jwt);
            token.setLogOut(false);
            token.setUser(user);
            tokenRepository.save(token);
        }

        private void removeAllTokenByUser(User user) {
            List<Token> validTokens = tokenRepository.findAllTokensByUserId(user.getId());
            if (validTokens.isEmpty()) {
                return;
            }
            validTokens.forEach(t -> {
                t.setLogOut(true);
            });
            tokenRepository.saveAll(validTokens);
        }


        public AuthResponse authenticate(User request) {
            authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            request.getUsername(),
                            request.getPassword()
                    )
            );

            User user = userRepository.findByEmail(request.getEmail())
                    .orElseThrow(() -> new UsernameNotFoundException("User not found"));

            if (!user.isActive()) {
                throw new RuntimeException("Account is not activated. Please check your email for activation link.");
            }

            String jwt = jwtService.generateToken(user);
            removeAllTokenByUser(user);
            saveUserToken(jwt, user);
            return new AuthResponse(jwt, "User Login Successful");
        }


        public String activeUser(int id) {
            User user = userRepository.findById(id)
                    .orElseThrow(() -> new RuntimeException("User not Found with this ID " + id));
            if (user != null) {
                user.setActive(true);
                userRepository.save(user);
                return "User Activated Successfully!";
            } else {
                return "Invalid Activation Token!";
            }
        }

    }

