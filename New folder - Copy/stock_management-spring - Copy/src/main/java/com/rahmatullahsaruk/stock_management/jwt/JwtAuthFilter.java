package com.rahmatullahsaruk.stock_management.jwt;
import com.rahmatullahsaruk.stock_management.service.UserService;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

    public class JwtAuthFilter extends OncePerRequestFilter {


        // Injecting JwtService to handle token operations (extract username, validate token)
        private final JwtService jwtService;

        // Injecting UserService to load user details from the database
        private final UserService userService;

        // Constructor-based Dependency Injection for JwtService and UserService
        public JwtAuthFilter(JwtService jwtService, UserService userService) {
            this.jwtService = jwtService;
            this.userService = userService;
        }

        @Override
        protected void doFilterInternal(
                HttpServletRequest request,
                HttpServletResponse response,
                FilterChain filterChain
        ) throws ServletException, IOException {

            System.out.println("JwtAuthFilter: Incoming request to " + request.getRequestURI());
            String authHeader = request.getHeader("Authorization");
            System.out.println("Authorization header: " + authHeader);

            if (authHeader == null || !authHeader.startsWith("Bearer ")) {
                System.out.println("No JWT token found, skipping filter.");
                filterChain.doFilter(request, response);
                return;
            }

            String token = authHeader.substring(7);
            String username = jwtService.extractUserName(token);
            System.out.println("Extracted Username from Token: " + username);

            // Proceed only if username is extracted and user is not already authenticated
            if (username != null && SecurityContextHolder.getContext().getAuthentication() == null) {

                // Loading user details (from DB) using UserService based on extracted username
                UserDetails userDetails = userService.loadUserByUsername(username);

                boolean valid = jwtService.isValid(token, userDetails);
                System.out.println("Token validation result: " + valid);
                // Validating the token against the loaded user details
                if (jwtService.isValid(token, userDetails)) {

                    // If token is valid, create an Authentication token (Spring Security standard)
                    UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(
                            userDetails,                      // Principal (user details)
                            null,                             // Credentials (password) — null since already authenticated
                            userDetails.getAuthorities()      // User roles/authorities
                    );

                    // Building web authentication details (like remote IP, session ID) from the request
                    authToken.setDetails(
                            new WebAuthenticationDetailsSource().buildDetails(request)
                    );

                    // Setting the authentication object in Spring Security's SecurityContext
                    SecurityContextHolder.getContext().setAuthentication(authToken);
                }
            }

            // Continue with the remaining filter chain (other filters, controllers, etc.)
            filterChain.doFilter(request, response);

        }

        @Override
        protected boolean shouldNotFilter(HttpServletRequest request) {
            String path = request.getRequestURI();
            System.out.println("Incoming Request Path: " + path);  // Add this log
            boolean skip = path.equals("/api/user/login") || path.startsWith("/images/") || path.startsWith("/api/user/active/") || path.startsWith("/api/auth/login") || path.startsWith("/api/super_admin/reg");
            System.out.println("Should Skip Filter: " + skip);  // Add this log
            return skip;
        }
    }


