package com.rahmatullahsaruk.stock_management.repository;

import com.rahmatullahsaruk.stock_management.entity.Employee;
import org.springframework.data.jpa.repository.JpaRepository;

    public interface EmployeeRepo extends JpaRepository<Employee,Long> {
    }

