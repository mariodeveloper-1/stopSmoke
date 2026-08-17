//
//  Health3DView.swift
//  STOPSMOKE
//
//  Created by Mario Balletta on 24/07/2026.
//

import SwiftUI
import SceneKit

/// Vista 3D Interattiva per la visualizzazione dell'impatto del fumo sul corpo umano.
struct Health3DView: View {
    @State var viewModel: DashboardViewModel
    
    /// Livello di danno biologico (da 0.0 a 1.0)
    @State private var damageLevel: Float = 0.0
    
    /// Modalità anteprima interattiva (consente all'utente di muovere lo slider)
    @State private var isInteractiveMode: Bool = false
    
    var body: some View {
        ZStack {
            // Sfondo scuro premium
            Color(red: 0.04, green: 0.04, blue: 0.07)
                .ignoresSafeArea()
            
            // Gradiente sottile che riflette il livello di danno
            RadialGradient(
                colors: [
                    damageColor.opacity(0.18),
                    Color(red: 0.08, green: 0.02, blue: 0.02).opacity(Double(damageLevel) * 0.35),
                    Color.clear
                ],
                center: .top,
                startRadius: 40,
                endRadius: 500
            )
            .ignoresSafeArea()
            
            VStack(spacing: 12) {
                // 1. Header compatto
                headerSection
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                
                // 2. Viewport 3D dedicato (riquadro pulito dove il corpo è al 100% visibile)
                ZStack(alignment: .bottomTrailing) {
                    SceneKit3DBodyContainer(damageLevel: damageLevel)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                    
                    // Overlay "Ruota 360°"
                    HStack(spacing: 5) {
                        Image(systemName: "hand.draw.fill")
                            .font(.system(size: 10))
                        Text(Localization.language == .italian ? "Ruota 360°" : "Rotate 360°")
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(.white.opacity(0.7))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.black.opacity(0.5))
                    .background(.ultraThinMaterial.opacity(0.4))
                    .cornerRadius(10)
                    .padding(12)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white.opacity(0.02))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.15),
                                    damageColor.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .shadow(color: damageColor.opacity(0.15), radius: 12, x: 0, y: 6)
                .padding(.horizontal, 16)
                
                // 3. Pannello controlli in basso (nessuna sovrapposizione col 3D)
                VStack(spacing: 8) {
                    damageSlider
                    organCards
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 85) // Spazio per Liquid Glass TabBar
            }
        }
        .onAppear {
            calculateAutomaticDamage()
        }
        .onChange(of: viewModel.cigarettesTodayCount) { _, _ in
            if !isInteractiveMode {
                calculateAutomaticDamage()
            }
        }
    }
    
    private func calculateAutomaticDamage() {
        let count = Float(viewModel.cigarettesTodayCount)
        let avg = Float(max(1, viewModel.dailyAverage))
        
        if count == 0 {
            let daysClean = Float(viewModel.daysSinceLastCigarette)
            let recoveryFactor = max(0.0, 1.0 - (daysClean * 0.15))
            damageLevel = recoveryFactor
        } else {
            let ratio = count / avg
            damageLevel = min(1.0, max(0.2, ratio))
        }
    }
    
    private var damageColor: Color {
        Color(
            red: Double(0.2 + (damageLevel * 0.8)),
            green: Double(0.8 * (1.0 - damageLevel)),
            blue: Double(0.3 * (1.0 - damageLevel))
        )
    }
}

// MARK: - Subviews
private extension Health3DView {
    
    var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(Localization.language == .italian ? "ANATOMIA & SALUTE" : "ANATOMY & HEALTH")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(.red.opacity(0.8))
                    .tracking(1.5)
                
                Text(Localization.language == .italian ? "Corpo 3D Interattivo" : "Interactive 3D Body")
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }
            Spacer()
            
            // Badge percentuale danno
            HStack(spacing: 4) {
                Circle()
                    .fill(damageColor)
                    .frame(width: 7, height: 7)
                
                Text("\(Int(damageLevel * 100))%")
                    .font(.system(size: 12, weight: .black, design: .monospaced))
                    .foregroundStyle(damageColor)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(damageColor.opacity(0.15))
            .background(.ultraThinMaterial)
            .cornerRadius(10)
        }
    }
    
    var damageSlider: some View {
        VStack(spacing: 4) {
            HStack {
                Text(Localization.language == .italian ? "SIMULATORE DANNO BIOLOGICO" : "BIOLOGICAL DAMAGE SIMULATOR")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
                    .tracking(1.0)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isInteractiveMode.toggle()
                        if !isInteractiveMode {
                            calculateAutomaticDamage()
                        }
                    }
                }) {
                    Text(isInteractiveMode ? "Auto" : (Localization.language == .italian ? "Simula" : "Simulate"))
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundStyle(.red)
                }
            }
            
            if isInteractiveMode {
                HStack(spacing: 10) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(.green)
                    
                    Slider(value: $damageLevel, in: 0.0...1.0)
                        .tint(damageColor)
                    
                    Image(systemName: "lungs.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(.red)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.5))
        .background(.ultraThinMaterial.opacity(0.3))
        .cornerRadius(12)
    }
    
    var organCards: some View {
        HStack(spacing: 8) {
            organStatusCard(
                icon: "lungs.fill",
                title: Localization.language == .italian ? "Polmoni" : "Lungs",
                statusText: damageLevel < 0.35 ? (Localization.language == .italian ? "Sani (Rosa)" : "Healthy") : (damageLevel < 0.70 ? (Localization.language == .italian ? "Nero Chiaro Misto" : "Tar Deposition") : (Localization.language == .italian ? "Nero Catrame 100%" : "Black Tar")),
                color: damageLevel < 0.35 ? .green : (damageLevel < 0.70 ? .orange : .red)
            )
            
            organStatusCard(
                icon: "heart.fill",
                title: Localization.language == .italian ? "Cuore" : "Heart",
                statusText: damageLevel < 0.35 ? (Localization.language == .italian ? "Normale" : "Normal") : (damageLevel < 0.70 ? (Localization.language == .italian ? "Stress" : "Stress") : (Localization.language == .italian ? "Rischio" : "At Risk")),
                color: damageLevel < 0.35 ? .green : (damageLevel < 0.70 ? .yellow : .red)
            )
        }
    }
    
    func organStatusCard(icon: String, title: String, statusText: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(color)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text(statusText)
                    .font(.system(size: 9, design: .rounded))
                    .foregroundStyle(color)
                    .lineLimit(1)
            }
            Spacer()
        }
        .padding(8)
        .frame(maxWidth: .infinity)
        .background(Color.black.opacity(0.5))
        .background(.ultraThinMaterial.opacity(0.3))
        .cornerRadius(10)
    }
}

// MARK: - SceneKit UIViewRepresentable Container
struct SceneKit3DBodyContainer: UIViewRepresentable {
    let damageLevel: Float
    
    private enum OrganType {
        case lung
        case heart
        case body
    }
    
    private func isPartIndex(_ index: Int, name: String, parentName: String) -> Bool {
        let targets = ["meshes_\(index)_", "tripo_part_\(index)", "part_\(index)"]
        if targets.contains(name) || targets.contains(parentName) {
            return true
        }
        let pattern = "(_|/|\\b)\(index)(_|/|\\b)"
        if name.range(of: pattern, options: .regularExpression) != nil ||
           parentName.range(of: pattern, options: .regularExpression) != nil {
            return true
        }
        return false
    }
    
    private func classifyNode(_ node: SCNNode) -> OrganType {
        let name = node.name ?? ""
        let parentName = node.parent?.name ?? ""
        let grandparentName = node.parent?.parent?.name ?? ""
        let context = "\(name)|\(parentName)|\(grandparentName)".lowercased()
        
        // Polmoni: PART 2 e PART 5
        if isPartIndex(2, name: name, parentName: parentName) ||
           isPartIndex(5, name: name, parentName: parentName) ||
           context.contains("lung") || context.contains("pulm") {
            return .lung
        }
        
        // Cuore e arterie: PART 18 e PART 19
        if isPartIndex(18, name: name, parentName: parentName) ||
           isPartIndex(19, name: name, parentName: parentName) ||
           context.contains("heart") || context.contains("artery") || context.contains("cardio") {
            return .heart
        }
        
        return .body
    }
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.backgroundColor = .clear
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = false
        scnView.antialiasingMode = .multisampling4X
        
        let scene: SCNScene
        if let url = Bundle.main.url(forResource: "human3D", withExtension: "usdc") ?? Bundle.main.url(forResource: "human3d", withExtension: "usdc"),
           let loadedScene = try? SCNScene(url: url, options: nil) {
            scene = loadedScene
        } else if let loadedScene = SCNScene(named: "human3D.usdc") ?? SCNScene(named: "human3d.usdc") {
            scene = loadedScene
        } else {
            scene = createFallbackProceduralScene()
        }
        
        scnView.scene = scene
        scene.background.contents = UIColor.clear
        
        centerModelTorsoAtOrigin(in: scene)
        makeGeometriesUnique(in: scene)
        addCustomLighting(to: scene)
        setupCamera(in: scene, scnView: scnView)
        applyMaterials(in: scene, damage: damageLevel)
        
        return scnView
    }
    
    private func centerModelTorsoAtOrigin(in scene: SCNScene) {
        guard scene.rootNode.childNode(withName: "stopsmoke_model_pivot", recursively: true) == nil else { return }
        
        let pivotNode = SCNNode()
        pivotNode.name = "stopsmoke_model_pivot"
        
        var modelNodes: [SCNNode] = []
        for child in scene.rootNode.childNodes {
            if !(child.name ?? "").hasPrefix("stopsmoke_") {
                modelNodes.append(child)
            }
        }
        
        for node in modelNodes {
            node.removeFromParentNode()
            pivotNode.addChildNode(node)
        }
        
        pivotNode.position = SCNVector3(0, 0.20, 0)
        scene.rootNode.addChildNode(pivotNode)
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        guard let scene = uiView.scene else { return }
        applyMaterials(in: scene, damage: damageLevel)
    }
    
    private func makeGeometriesUnique(in scene: SCNScene) {
        scene.rootNode.enumerateChildNodes { (node, _) in
            if let geometry = node.geometry, let copy = geometry.copy() as? SCNGeometry {
                node.geometry = copy
            }
        }
    }
    
    // MARK: - Setup Scena & Luci
    
    private func addCustomLighting(to scene: SCNScene) {
        guard scene.rootNode.childNode(withName: "stopsmoke_ambient_light", recursively: true) == nil else { return }
        
        var lightsToRemove: [SCNNode] = []
        scene.rootNode.enumerateChildNodes { (node, _) in
            if node.light != nil && !(node.name ?? "").hasPrefix("stopsmoke_") {
                lightsToRemove.append(node)
            }
        }
        for light in lightsToRemove {
            light.removeFromParentNode()
        }
        
        let ambientNode = SCNNode()
        ambientNode.name = "stopsmoke_ambient_light"
        let ambient = SCNLight()
        ambient.type = .ambient
        ambient.color = UIColor(white: 0.70, alpha: 1.0)
        ambient.intensity = 1000
        ambientNode.light = ambient
        scene.rootNode.addChildNode(ambientNode)
        
        let frontLightNode = SCNNode()
        frontLightNode.name = "stopsmoke_front_light"
        let frontLight = SCNLight()
        frontLight.type = .directional
        frontLight.color = UIColor.white
        frontLight.intensity = 1800
        frontLightNode.light = frontLight
        frontLightNode.position = SCNVector3(x: 0, y: 1.5, z: 5)
        frontLightNode.look(at: SCNVector3Zero)
        scene.rootNode.addChildNode(frontLightNode)
        
        let rimLightNode = SCNNode()
        rimLightNode.name = "stopsmoke_rim_light"
        let rimLight = SCNLight()
        rimLight.type = .directional
        rimLight.color = UIColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 1.0)
        rimLight.intensity = 1200
        rimLightNode.light = rimLight
        rimLightNode.position = SCNVector3(x: -3, y: 2, z: -3)
        rimLightNode.look(at: SCNVector3Zero)
        scene.rootNode.addChildNode(rimLightNode)
    }
    
    private func setupCamera(in scene: SCNScene, scnView: SCNView) {
        var camerasToRemove: [SCNNode] = []
        scene.rootNode.enumerateChildNodes { (node, _) in
            if node.camera != nil {
                camerasToRemove.append(node)
            }
        }
        for cam in camerasToRemove {
            cam.removeFromParentNode()
        }
        
        let cameraNode = SCNNode()
        cameraNode.name = "stopsmoke_camera"
        let camera = SCNCamera()
        camera.fieldOfView = 42
        camera.zNear = 0.01
        camera.zFar = 100
        cameraNode.camera = camera
        
        let targetPos = SCNVector3(x: 0, y: 0.20, z: 0)
        cameraNode.position = SCNVector3(x: 0, y: 0.20, z: 1.85)
        
        let lookTarget = SCNNode()
        lookTarget.name = "stopsmoke_look_target"
        lookTarget.position = targetPos
        scene.rootNode.addChildNode(lookTarget)
        
        let constraint = SCNLookAtConstraint(target: lookTarget)
        constraint.isGimbalLockEnabled = true
        cameraNode.constraints = [constraint]
        
        scene.rootNode.addChildNode(cameraNode)
        
        scnView.pointOfView = cameraNode
        scnView.defaultCameraController.target = targetPos
        scnView.defaultCameraController.pointOfView = cameraNode
    }
    
    // MARK: - Applicazione Materiali & Interpolazione Sfumata Polmoni (120 FPS)
    
    private func applyMaterials(in scene: SCNScene, damage: Float) {
        let d = max(0.0, min(1.0, CGFloat(damage)))
        
        // --- TRANSIZIONE SFUMATA POLMONI MULTI-STADIO ---
        // 0% -> 35%: Rosa Naturale (#FF5878) -> Rosa Intenso (#D81B4E)
        // 35% -> 70%: Rosa Intenso -> Nero Chiaro Misto Rosa / Antracite (#2E1A22)
        // 70% -> 100%: Nero Chiaro Antracite -> NERO CATRAME ASSOLUTO (#000000)
        
        let lungColor: UIColor
        let lungEmission: UIColor
        
        if d <= 0.35 {
            let p = d / 0.35
            let healthyColor = UIColor(red: 1.00, green: 0.35, blue: 0.47, alpha: 1.0)
            let intensePinkColor = UIColor(red: 0.85, green: 0.12, blue: 0.30, alpha: 1.0)
            lungColor = lerpColor(from: healthyColor, to: intensePinkColor, progress: p)
            lungEmission = healthyColor.withAlphaComponent(CGFloat(0.85 * (1.0 - (p * 0.25))))
        } else if d <= 0.70 {
            let p = (d - 0.35) / 0.35
            let intensePinkColor = UIColor(red: 0.85, green: 0.12, blue: 0.30, alpha: 1.0)
            let lightBlackColor = UIColor(red: 0.18, green: 0.10, blue: 0.14, alpha: 1.0) // Nero chiaro sfumato di rosa
            lungColor = lerpColor(from: intensePinkColor, to: lightBlackColor, progress: p)
            lungEmission = intensePinkColor.withAlphaComponent(CGFloat(0.64 * (1.0 - p)))
        } else {
            let p = (d - 0.70) / 0.30
            let lightBlackColor = UIColor(red: 0.18, green: 0.10, blue: 0.14, alpha: 1.0)
            let totalBlackColor = UIColor(red: 0.00, green: 0.00, blue: 0.00, alpha: 1.0)
            lungColor = lerpColor(from: lightBlackColor, to: totalBlackColor, progress: p)
            lungEmission = UIColor.black
        }
        
        // Cuore/Arterie: Rosso Vivo -> Viola Scuro Ostruito
        let healthyHeartColor = UIColor(red: 0.95, green: 0.08, blue: 0.15, alpha: 1.0)
        let damagedHeartColor = UIColor(red: 0.15, green: 0.02, blue: 0.05, alpha: 1.0)
        let heartColor = lerpColor(from: healthyHeartColor, to: damagedHeartColor, progress: d)
        
        let organRoughness = NSNumber(value: Float(0.20 + (d * 0.70)))
        let glassColor = UIColor(red: 0.15, green: 0.22, blue: 0.35, alpha: 1.0)
        
        scene.rootNode.enumerateChildNodes { (node, _) in
            guard let geometry = node.geometry else { return }
            
            let organ = classifyNode(node)
            let mat: SCNMaterial
            if let existingMat = geometry.firstMaterial {
                mat = existingMat
            } else {
                mat = SCNMaterial()
                geometry.materials = [mat]
            }
            
            mat.lightingModel = .phong
            mat.locksAmbientWithDiffuse = true
            
            switch organ {
            case .lung:
                // Polmoni (Part 2 e 5): opachi con sfumatura graduata fluida
                mat.diffuse.contents = lungColor
                mat.transparency = 1.0
                mat.blendMode = .replace
                mat.writesToDepthBuffer = true
                mat.readsFromDepthBuffer = true
                mat.isDoubleSided = true
                mat.roughness.contents = organRoughness
                mat.specular.contents = UIColor.white.withAlphaComponent(0.4)
                mat.emission.contents = lungEmission
                node.renderingOrder = -50
                
            case .heart:
                mat.diffuse.contents = heartColor
                mat.transparency = 1.0
                mat.blendMode = .replace
                mat.writesToDepthBuffer = true
                mat.readsFromDepthBuffer = true
                mat.isDoubleSided = true
                mat.roughness.contents = organRoughness
                mat.specular.contents = UIColor.white.withAlphaComponent(0.5)
                mat.emission.contents = heartColor.withAlphaComponent(CGFloat(0.4 * (1.0 - d)))
                node.renderingOrder = -50
                
            case .body:
                mat.diffuse.contents = glassColor
                mat.transparency = 0.22
                mat.blendMode = .alpha
                mat.isDoubleSided = true
                mat.writesToDepthBuffer = false
                mat.readsFromDepthBuffer = true
                mat.fresnelExponent = 1.8
                mat.specular.contents = UIColor(red: 0.6, green: 0.8, blue: 1.0, alpha: 0.6)
                mat.roughness.contents = NSNumber(value: 0.3)
                mat.emission.contents = UIColor.clear
                node.renderingOrder = 100
            }
        }
    }
    
    // MARK: - Helpers
    
    private func lerpColor(from start: UIColor, to end: UIColor, progress: CGFloat) -> UIColor {
        let p = max(0.0, min(1.0, CGFloat(progress)))
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        
        start.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        end.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        return UIColor(
            red: r1 + (r2 - r1) * p,
            green: g1 + (g2 - g1) * p,
            blue: b1 + (b2 - b1) * p,
            alpha: a1 + (a2 - a1) * p
        )
    }
    
    private func createFallbackProceduralScene() -> SCNScene {
        let scene = SCNScene()
        
        let bodyGeo = SCNCylinder(radius: 0.5, height: 1.8)
        let bodyNode = SCNNode(geometry: bodyGeo)
        bodyNode.name = "human_body"
        scene.rootNode.addChildNode(bodyNode)
        
        let leftLungNode = SCNNode(geometry: SCNSphere(radius: 0.18))
        leftLungNode.name = "tripo_part_2"
        leftLungNode.position = SCNVector3(x: -0.2, y: 0.3, z: 0)
        scene.rootNode.addChildNode(leftLungNode)
        
        let rightLungNode = SCNNode(geometry: SCNSphere(radius: 0.18))
        rightLungNode.name = "tripo_part_5"
        rightLungNode.position = SCNVector3(x: 0.2, y: 0.3, z: 0)
        scene.rootNode.addChildNode(rightLungNode)
        
        let heartNode = SCNNode(geometry: SCNSphere(radius: 0.12))
        heartNode.name = "tripo_part_18"
        heartNode.position = SCNVector3(x: 0, y: 0.25, z: 0.08)
        scene.rootNode.addChildNode(heartNode)
        
        return scene
    }
}

#Preview {
    Health3DView(viewModel: DashboardViewModel(service: SmokingService.preview))
}
