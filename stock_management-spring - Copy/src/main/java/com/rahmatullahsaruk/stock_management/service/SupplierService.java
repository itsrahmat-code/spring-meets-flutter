package com.rahmatullahsaruk.stock_management.service;

import com.rahmatullahsaruk.stock_management.entity.Supplier;
import com.rahmatullahsaruk.stock_management.repository.SupplierRepo;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@Service
public class SupplierService {

    private final SupplierRepo supplierRepo;

    public SupplierService(SupplierRepo supplierRepo) {
        this.supplierRepo = supplierRepo;
    }

    public List<Supplier> getAllSuppliers() {
        return supplierRepo.findAll();
    }

    public Supplier getSupplierById(Long id) {
        return supplierRepo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Supplier not found with id " + id));
    }

    public Supplier createSupplier(Supplier supplier) {
        // Add any defaulting/validation here if needed
        return supplierRepo.save(supplier);
    }

    public Supplier updateSupplier(Long id, Supplier updated) {
        return supplierRepo.findById(id).map(supplier -> {
            supplier.setContactPerson(updated.getContactPerson());
            supplier.setPhone(updated.getPhone());
            supplier.setEmail(updated.getEmail());
            supplier.setAddress(updated.getAddress());
            supplier.setCompanyName(updated.getCompanyName());
            return supplierRepo.save(supplier);
        }).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Supplier not found with id " + id));
    }

    public void deleteSupplier(Long id) {
        if (!supplierRepo.existsById(id)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Supplier not found with id " + id);
        }
        supplierRepo.deleteById(id);
    }
}
