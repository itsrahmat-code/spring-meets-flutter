package com.rahmatullahsaruk.stock_management.dto;
import java.util.Date;

    public class ManagerDTO {



        private Long id;

        private String name;
        private String email;
        private String phone;
        private String gender;
        private String address;
        private Date dateOfBirth;
        private String photo;

        public ManagerDTO() {
        }

        public ManagerDTO(Long id, String name, String email, String phone, String gender, String address, Date dateOfBirth, String photo) {
            this.id = id;
            this.name = name;
            this.email = email;
            this.phone = phone;
            this.gender = gender;
            this.address = address;
            this.dateOfBirth = dateOfBirth;
            this.photo = photo;
        }


        public String getPhoto() {
            return photo;
        }

        public void setPhoto(String photo) {
            this.photo = photo;
        }

        public Date getDateOfBirth() {
            return dateOfBirth;
        }

        public void setDateOfBirth(Date dateOfBirth) {
            this.dateOfBirth = dateOfBirth;
        }

        public String getAddress() {
            return address;
        }

        public void setAddress(String address) {
            this.address = address;
        }

        public String getGender() {
            return gender;
        }

        public void setGender(String gender) {
            this.gender = gender;
        }

        public String getPhone() {
            return phone;
        }

        public void setPhone(String phone) {
            this.phone = phone;
        }

        public String getEmail() {
            return email;
        }

        public void setEmail(String email) {
            this.email = email;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public Long getId() {
            return id;
        }

        public void setId(Long id) {
            this.id = id;
        }


    }
