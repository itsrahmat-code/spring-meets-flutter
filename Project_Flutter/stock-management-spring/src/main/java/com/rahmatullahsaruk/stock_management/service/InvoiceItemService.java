package com.rahmatullahsaruk.stock_management.service;


import com.rahmatullahsaruk.stock_management.dto.InvoiceItemDTO;
import com.rahmatullahsaruk.stock_management.entity.InvoiceItem;
import com.rahmatullahsaruk.stock_management.entity.Product;
import com.rahmatullahsaruk.stock_management.repository.InvoiceItemRepo;
import com.rahmatullahsaruk.stock_management.repository.ProductRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class InvoiceItemService {

    @Autowired
    private InvoiceItemRepo invoiceItemRepo;

    @Autowired
    private ProductRepo productRepo;

    // Get all invoice items
    public List<InvoiceItemDTO> getAllInvoiceItems() {
        return invoiceItemRepo.findAll()
                .stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    // Get invoice item by ID
    public InvoiceItemDTO getInvoiceItemById(Long id) {
        Optional<InvoiceItem> optional = invoiceItemRepo.findById(id);
        return optional.map(this::convertToDTO).orElse(null);
    }

    // Create new invoice item
    public InvoiceItemDTO createInvoiceItem(InvoiceItemDTO dto) {
        Product product = productRepo.findById(dto.getProductId())
                .orElseThrow(() -> new RuntimeException("Product not found"));

        InvoiceItem invoiceItem = new InvoiceItem();
        invoiceItem.setProduct(product);
        invoiceItem.setQuantity(dto.getQuantity());
        invoiceItem.setPriceAtSale(dto.getPriceAtSale());

        InvoiceItem saved = invoiceItemRepo.save(invoiceItem);
        return convertToDTO(saved);
    }

    // Delete invoice item
    public void deleteInvoiceItem(Long id) {
        invoiceItemRepo.deleteById(id);
    }

    // Convert entity to DTO
    private InvoiceItemDTO convertToDTO(InvoiceItem item) {
        InvoiceItemDTO dto = new InvoiceItemDTO();
        dto.setProductId(item.getProduct().getId());
        dto.setProductName(item.getProduct().getName()); // Assumes Product has getName()
        dto.setQuantity(item.getQuantity());
        dto.setPriceAtSale(item.getPriceAtSale());
        return dto;
    }
}
