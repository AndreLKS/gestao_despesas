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

    public List<Despesas> listarTodas() {
        return despesaRepository.findAll();
    }

    public Optional<Despesas> buscarPorId(Long id) {
        return despesaRepository.findById(id);
    }

    public Despesas salvar(Despesas despesa) {
        return despesaRepository.save(despesa);
    }

    public Despesas atualizar(Long id, Despesas despesa) {
        if (!despesaRepository.existsById(id)) {
            throw new RuntimeException("Despesa não encontrada");
        }
        despesa.setId(id);
        return despesaRepository.save(despesa);
    }

    public void deletar(Long id) {
        despesaRepository.deleteById(id);
    }
}
