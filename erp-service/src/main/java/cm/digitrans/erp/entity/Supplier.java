package cm.digitrans.erp.entity;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "suppliers")
@Data
public class Supplier {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String nom;
    private String contact;
    private String localisation;
}
