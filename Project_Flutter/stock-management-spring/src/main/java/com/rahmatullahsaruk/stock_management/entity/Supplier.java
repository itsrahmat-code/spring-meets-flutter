package com.rahmatullahsaruk.stock_management.entity;

import jakarta.persistence.*;

    @Entity
    @Table(name = "suppliers")
    public class Supplier {

        @Id
        @GeneratedValue(strategy = GenerationType.IDENTITY)
        private Long id;
        private String contactPerson;
        private String phone;
        private String email;
        private String address;
        private String companyName;

        public Supplier() {
        }

        public Supplier(Long id, String contactPerson,
                        String phone, String email, String address,
                        String companyName) {
            this.id = id;

            this.contactPerson = contactPerson;
            this.phone = phone;
            this.email = email;
            this.address = address;
            this.companyName = companyName;
        }

        public Long getId() {
            return id;
        }

        public void setId(Long id) {
            this.id = id;
        }



        public String getContactPerson() {
            return contactPerson;
        }

        public void setContactPerson(String contactPerson) {
            this.contactPerson = contactPerson;
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

        public String getAddress() {
            return address;
        }

        public void setAddress(String address) {
            this.address = address;
        }

        public String getCompanyName() {
            return companyName;
        }

        public void setCompanyName(String companyName) {
            this.companyName = companyName;
        }
    }

