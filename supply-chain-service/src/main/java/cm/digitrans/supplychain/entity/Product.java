package cm.digitrans.supplychain.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.io.Serializable;

@Entity
@Table(name = "products")
@Data
public class Product implements Serializable {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String nom;
    private String categorie;
    private Integer quantite;
}
