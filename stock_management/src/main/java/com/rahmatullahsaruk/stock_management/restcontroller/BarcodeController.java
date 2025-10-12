package com.rahmatullahsaruk.stock_management.restcontroller;
import com.rahmatullahsaruk.stock_management.service.BarcodeService;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

    @RestController
    @RequestMapping("/api/barcodes")
    public class BarcodeController {

        private final BarcodeService barcodeService;

        public BarcodeController(BarcodeService barcodeService) {
            this.barcodeService = barcodeService;
        }

        @GetMapping(value = "/{code}", produces = MediaType.IMAGE_PNG_VALUE)
        public ResponseEntity<byte[]> getBarcode(@PathVariable String code) {
            try {
                byte[] image = barcodeService.generateBarcodeImage(code);

                HttpHeaders headers = new HttpHeaders();
                headers.setContentType(MediaType.IMAGE_PNG);

                return new ResponseEntity<>(image, headers, HttpStatus.OK);
            } catch (Exception e) {
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
            }
        }
    }


