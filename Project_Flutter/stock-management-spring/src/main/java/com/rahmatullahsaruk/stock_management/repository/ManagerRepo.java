package com.rahmatullahsaruk.stock_management.repository;
import com.rahmatullahsaruk.stock_management.entity.Manager;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

    @Repository
    public interface ManagerRepo extends JpaRepository<Manager,Long> {


        Optional<Manager> findByUserId(int userId);

        Optional<Manager> findByEmail(String email);


    }

