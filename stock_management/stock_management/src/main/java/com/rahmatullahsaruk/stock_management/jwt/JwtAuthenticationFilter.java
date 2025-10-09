package com.rahmatullahsaruk.stock_management.jwt;
import com.eiasinprodhan.crems.service.UserService;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

        private final JwtService jwtService;

        private final UserService userService;

        public JwtAuthenticationFilter(JwtService jwtService, UserService userService) {
            this.jwtService = jwtService;
            this.userService = userService;
        }


        @Override
        protected void doFilterInternal(
                HttpServletRequest request,
                HttpServletResponse response,
                FilterChain filterChain
        ) throws ServletException, IOException {


            System.out.println("JwtAuthenticationFilter: Incoming request to " + request.getRequestURI());
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

            if (username != null && SecurityContextHolder.getContext().getAuthentication() == null) {

                UserDetails userDetails = userService.loadUserByUsername(username);

                System.out.println(userDetails);

                boolean valid = jwtService.isValid(token, userDetails);
                System.out.println("Token validation result: " + valid);

                if (jwtService.isValid(token, userDetails)) {


                    UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(
                            userDetails,
                            null,
                            userDetails.getAuthorities()
                    );

                    authToken.setDetails(
                            new WebAuthenticationDetailsSource().buildDetails(request)
                    );

                    SecurityContextHolder.getContext().setAuthentication(authToken);
                }
            }

            filterChain.doFilter(request, response);
        }

        @Override
        protected boolean shouldNotFilter(HttpServletRequest request) {
            String path = request.getRequestURI();
            System.out.println("Incoming Request Path: " + path);
            boolean skip = path.startsWith("/images/") || path.startsWith("/api/user/active/") || path.startsWith("/api/auth/login");
            System.out.println("Should Skip Filter: " + skip);
            return skip;
        }


    }

