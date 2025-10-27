package com.rahmatullahsaruk.stock_management.restcontroller;
import com.rahmatullahsaruk.stock_management.dto.InvoiceItemDTO;
import com.rahmatullahsaruk.stock_management.repository.InvoiceItemRepo;
import com.rahmatullahsaruk.stock_management.service.InvoiceItemService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/invoiceitem")
public class InvoiceItemController {

    @Autowired
    private InvoiceItemService invoiceItemService;
    @Autowired
    private InvoiceItemRepo invoiceItemRepo;

    @GetMapping
    public List<InvoiceItemDTO> getAllItems() {
        return invoiceItemService.getAllInvoiceItems();
    }

    @GetMapping("/{id}")
    public InvoiceItemDTO getById(@PathVariable Long id) {
        return invoiceItemService.getInvoiceItemById(id);
    }

    @PostMapping
    public InvoiceItemDTO create(@RequestBody InvoiceItemDTO dto) {
        return invoiceItemService.createInvoiceItem(dto);
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable Long id) {
        invoiceItemService.deleteInvoiceItem(id);
    }
}
