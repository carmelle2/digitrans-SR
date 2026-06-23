package cm.digitrans.erp.service;

import cm.digitrans.erp.entity.Supplier;
import cm.digitrans.erp.repository.SupplierRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class SupplierService {
    private final SupplierRepository supplierRepository;

    public List<Supplier> findAll() {
        return supplierRepository.findAll();
    }

    public Supplier save(Supplier supplier) {
        return supplierRepository.save(supplier);
    }
}
