package com.rahmatullahsaruk.stock_management.dto;

    public class AuthDTO {

        private  String token;
        private String message;

        public AuthDTO() {
        }

        public AuthDTO(String token, String message) {
            this.token = token;
            this.message = message;
        }

        public String getToken() {
            return token;
        }

        public void setToken(String token) {
            this.token = token;
        }

        public String getMessage() {
            return message;
        }

        public void setMessage(String message) {
            this.message = message;
        }
    }

