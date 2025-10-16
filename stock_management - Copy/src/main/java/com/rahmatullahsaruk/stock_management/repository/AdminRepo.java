package com.rahmatullahsaruk.stock_management.repository;
import com.rahmatullahsaruk.stock_management.entity.Admin;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

    @Repository
    public interface AdminRepo extends JpaRepository<Admin, Long> {


        Optional<Admin> findByUserId(int userId);

        Optional<Admin> findByEmail(String email);

    }

