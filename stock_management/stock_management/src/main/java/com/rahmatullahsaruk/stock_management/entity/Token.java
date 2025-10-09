package com.rahmatullahsaruk.stock_management.entity;
import jakarta.persistence.*;

@Entity
public class Token {

        @Id
        @GeneratedValue(strategy = GenerationType.IDENTITY)
        private Integer id;

        private String token;

        @Column(name = "is_log_out")
        private Boolean logout;

        @ManyToOne(fetch = FetchType.LAZY)
        @JoinColumn(name = "user_id")
        private User user;

        public Token() {
        }

        public Token(Integer id, String token, Boolean logout, User user) {
            this.id = id;
            this.token = token;
            this.logout = logout;
            this.user = user;
        }

        public Integer getId() {
            return id;
        }

        public void setId(Integer id) {
            this.id = id;
        }

        public String getToken() {
            return token;
        }

        public void setToken(String token) {
            this.token = token;
        }

        public Boolean getLogOut() {
            return logout;
        }

        public void setLogOut(Boolean logOut) {
            logout = logOut;
        }

        public User getUser() {
            return user;
        }

        public void setUser(User user) {
            this.user = user;
        }
    }

