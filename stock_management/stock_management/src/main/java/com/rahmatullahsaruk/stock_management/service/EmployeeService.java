package com.rahmatullahsaruk.stock_management.service;
import com.rahmatullahsaruk.stock_management.entity.Employee;
import com.rahmatullahsaruk.stock_management.repository.IEmployeeRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

    @Service
    public class EmployeeService {

        @Autowired
        private IEmployeeRepository employeeRepository;

        @Autowired
        private PhotoService photoService;

        public List<Employee> findAll() {
            return employeeRepository.findAll();
        }

        public Employee findById(int id) {
            return employeeRepository.findById(id).get();
        }

        public List<Employee> findByRole(String role) {
            return employeeRepository.findByRole(role);
        }

        public Employee save(Employee employee) {
            return employeeRepository.save(employee);
        }

        public Employee update(Employee employee, MultipartFile file) {
            if(file != null && !file.isEmpty()) {
                String fileName = photoService.savePhoto(employee, "/employees",  file);
                employee.setPhoto(fileName);
            }
            return employeeRepository.save(employee);
        }

        public Employee update(Employee employee) {
            return employeeRepository.save(employee);
        }

        public void delete(int id) {
            employeeRepository.deleteById(id);
        }

        public Employee login(String email, String password) {
            Employee employee = employeeRepository.findByEmail(email);

            if (!employee.getPassword().equals(password)) {
                throw new RuntimeException("Wrong password.");
            };
            return employee;
        }

        public Employee findByEmail(String email) {
            return employeeRepository.findByEmail(email);
        }
    }

