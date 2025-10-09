package com.rahmatullahsaruk.stock_management.restcontroller;
import com.rahmatullahsaruk.stock_management.dto.AuthResponse;
import com.rahmatullahsaruk.stock_management.entity.User;
import com.rahmatullahsaruk.stock_management.repository.ITokenRepository;
import com.rahmatullahsaruk.stock_management.service.AuthService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

    @RestController
    @RequestMapping("/api/auth")
    public class AuthRestController {

        @Autowired
        private AuthService authService;

        @Autowired
        private ITokenRepository tokenRepository;


        @PostMapping("/login")
        public ResponseEntity<AuthResponse> login(@RequestBody User request){
            return ResponseEntity.ok(authService.authenticate(request));
        }

        @GetMapping("/active/{id}")
        public ResponseEntity<String> activeUser(@PathVariable("id") int id){

            String response= authService.activeUser(id);
            return  ResponseEntity.ok(response);
        }

        @PostMapping("/logout")
        public ResponseEntity<String> logout(HttpServletRequest request) {
            final String authHeader = request.getHeader("Authorization");

            if (authHeader == null || !authHeader.startsWith("Bearer ")) {
                return ResponseEntity.badRequest().body("Missing or invalid Authorization header.");
            }

            String token = authHeader.substring(7);
            tokenRepository.findByToken(token).ifPresent(savedToken -> {
                savedToken.setLogOut(true);
                tokenRepository.save(savedToken);
            });
            return ResponseEntity.ok("Logged out successfully.");
        }
    }

