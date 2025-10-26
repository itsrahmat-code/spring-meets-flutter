package com.rahmatullahsaruk.stock_management.restcontroller;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.rahmatullahsaruk.stock_management.entity.Employee;
import com.rahmatullahsaruk.stock_management.service.EmployeeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.*;

    @RestController
    @RequestMapping("/api/employee")
    @CrossOrigin("*")
    public class EmployeeController {

        private final EmployeeService employeeService;

        @Autowired
        public EmployeeController(EmployeeService employeeService) {
            this.employeeService = employeeService;
        }

        // Create employee with image
        @PostMapping("add")
        public ResponseEntity<Map<String, String>> saveEmployee(
                @RequestPart("employee") String employeeJson,
                @RequestParam(value = "photo") MultipartFile photo
        ) {
            try {
                ObjectMapper objectMapper = new ObjectMapper();
                Employee employee = objectMapper.readValue(employeeJson, Employee.class);

                employeeService.createEmployee(employee, photo);

                Map<String, String> response = new HashMap<>();
                response.put("message", "Employee added successfully");
                return new ResponseEntity<>(response, HttpStatus.OK);

            } catch (JsonProcessingException e) {
                return new ResponseEntity<>(Map.of("message", "Invalid employee JSON: " + e.getMessage()), HttpStatus.BAD_REQUEST);
            } catch (Exception e) {
                return new ResponseEntity<>(Map.of("message", "Failed to add employee: " + e.getMessage()), HttpStatus.INTERNAL_SERVER_ERROR);
            }
        }

        // Get all employees
        @GetMapping("")
        public List<Employee> getAllEmployees() {
            return employeeService.getAllEmployees();
        }

        // Get employee by ID
        @GetMapping("/{id}")
        public ResponseEntity<Employee> getEmployeeById(@PathVariable Long id) {
            Employee employee = employeeService.getEmployeeById(id);
            return employee != null
                    ? new ResponseEntity<>(employee, HttpStatus.OK)
                    : new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }

        // Update employee
        @PutMapping("/{id}")
        public ResponseEntity<Employee> updateEmployee(
                @PathVariable Long id,
                @RequestBody Employee employeeDetails) {
            Employee updated = employeeService.updateEmployee(id, employeeDetails);
            return updated != null
                    ? new ResponseEntity<>(updated, HttpStatus.OK)
                    : new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }

        // Delete employee
        @DeleteMapping("/{id}")
        public ResponseEntity<Map<String, String>> deleteEmployee(@PathVariable Long id) {
            try {
                employeeService.deleteEmployee(id);
                return new ResponseEntity<>(Map.of("message", "Employee deleted successfully"), HttpStatus.OK);
            } catch (Exception e) {
                return new ResponseEntity<>(Map.of("message", "Failed to delete employee: " + e.getMessage()), HttpStatus.INTERNAL_SERVER_ERROR);
            }
        }
    }

