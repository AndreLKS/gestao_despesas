package com.gestaodespesas.repository;

import com.gestaodespesas.model.Despesas;
import org.springframework.data.jpa.repository.JpaRepository;

public interface DespesaRepository extends JpaRepository<Despesas, Long> {
    // Métodos customizados podem ser adicionados aqui se necessário
}
