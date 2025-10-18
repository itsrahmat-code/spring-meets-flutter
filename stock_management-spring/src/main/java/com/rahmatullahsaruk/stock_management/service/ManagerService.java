package com.rahmatullahsaruk.stock_management.service;

import com.rahmatullahsaruk.stock_management.dto.ManagerDTO;
import com.rahmatullahsaruk.stock_management.entity.Manager;
import com.rahmatullahsaruk.stock_management.repository.ManagerRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

    @Service
    public class ManagerService {

        @Autowired
        private ManagerRepo managerRepo;

        public List<Manager> getAllManagers() {
            return managerRepo.findAll();

        }


        public List<ManagerDTO> getAllManagerDTO() {
            return managerRepo.findAll().stream().map(manager -> {
                ManagerDTO dto = new ManagerDTO();


                dto.setId(manager.getId());
                dto.setEmail(manager.getEmail());
                dto.setName(manager.getName());
                dto.setAddress(manager.getAddress());
                dto.setPhone(manager.getPhone());
                dto.setGender(manager.getGender());
                dto.setPhoto(manager.getPhoto());
                dto.setDateOfBirth(manager.getDateOfBirth());


                return dto;
            }).toList();
        }




        public Manager save(Manager manager) {
            return managerRepo.save(manager);
        }

        public void delete(Long id) {
            managerRepo.deleteById(id);
        }

        public Manager getProfileByUserId(int userId) {
            return managerRepo.findByUserId(userId)
                    .orElseThrow(() -> new RuntimeException("Manager not found"));
        }
    }


