        end
    end)
    
    Fly()  -- Start flying automatically
end

-- Connect buttons
enableButton.MouseButton1Click:Connect(enableFling)
respawnButton.MouseButton1Click:Connect(respawn)
