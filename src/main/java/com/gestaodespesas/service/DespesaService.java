package com.gestaodespesas.service;

import com.gestaodespesas.model.Despesas;
import com.gestaodespesas.repository.DespesaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class DespesaService {

    @Autowired
    private DespesaRepository despesaRepository;

    // Método para obter todas as despesas
    public List<Despesas> listarDespesas() {
        return despesaRepository.findAll();
    }

    // Método para salvar uma despesa
    public Despesas salvarDespesa(Despesas despesa) {
        return despesaRepository.save(despesa);
    }

    // Método para buscar uma despesa por id
    public Optional<Despesas> buscarDespesaPorId(Long id) {
        return despesaRepository.findById(id);
    }
}
