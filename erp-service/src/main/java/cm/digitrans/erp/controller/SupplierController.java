package cm.digitrans.erp.controller;

import cm.digitrans.erp.entity.Supplier;
import cm.digitrans.erp.service.SupplierService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/suppliers")
@RequiredArgsConstructor
public class SupplierController {
    private final SupplierService supplierService;

    @GetMapping
    public ResponseEntity<List<Supplier>> getAll() {
        return ResponseEntity.ok(supplierService.findAll());
    }

    @PostMapping
    public ResponseEntity<Supplier> create(@RequestBody Supplier supplier) {
        return ResponseEntity.ok(supplierService.save(supplier));
    }
}
