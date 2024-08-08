if game:GetService("RunService"):IsClient() then
	return require(script:WaitForChild("Shared"):WaitForChild("ReplicaController"))
else
	script:WaitForChild("Server"):WaitForChild("ReplicaService").Parent = game:GetService("ServerScriptService")
	return require(script.Server:WaitForChild("Experimental"):WaitForChild("ReplicaServiceListeners"))
end
