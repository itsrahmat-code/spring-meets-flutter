package com.rahmatullahsaruk.stock_management.repository;
import com.rahmatullahsaruk.stock_management.entity.Employee;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

    @Repository
    public interface IEmployeeRepository extends JpaRepository<Employee, Integer> {
        List<Employee> findByRole(String role);
        Employee findByEmail(String email);
    }

