import SwiftUI
import PDFKit

class PDFGeneratorService {

    // MARK: - PDF Generation

    func generatePDF(
        entries: [MealEntry],
        userSettings: UserSettings,
        dateRange: ClosedRange<Date>
    ) -> Data? {
        let format = UIGraphicsPDFRendererFormat()
        let pageWidth: CGFloat = 612  // Letter size
        let pageHeight: CGFloat = 792
        let margin = Config.pdfPageMargin

        let renderer = UIGraphicsPDFRenderer(
            bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight),
            format: format
        )

        let data = renderer.pdfData { context in
            context.beginPage()

            var currentY: CGFloat = margin

            // Header
            currentY = drawHeader(
                context: context,
                dateRange: dateRange,
                userSettings: userSettings,
                pageWidth: pageWidth,
                margin: margin,
                y: currentY
            )

            // Group entries by day
            let sortedEntries = entries.sorted { $0.timestamp < $1.timestamp }
            let groupedEntries = Dictionary(grouping: sortedEntries) { entry -> Date in
                let calendar = Calendar.current
                return calendar.startOfDay(for: entry.timestamp)
            }

            // Sort days chronologically
            let sortedDays = groupedEntries.keys.sorted()

            var isFirstDay = true
            for day in sortedDays {
                guard let dayEntries = groupedEntries[day] else { continue }

                // Start new page for each day (except first)
                if !isFirstDay {
                    context.beginPage()
                    currentY = margin
                } else {
                    isFirstDay = false
                }

                // Draw day header
                currentY = drawDayHeader(
                    context: context,
                    date: day,
                    entryCount: dayEntries.count,
                    pageWidth: pageWidth,
                    margin: margin,
                    y: currentY
                )

                // Draw table header for this day
                currentY = drawTableHeader(
                    context: context,
                    pageWidth: pageWidth,
                    margin: margin,
                    y: currentY
                )

                // Draw entries for this day
                for entry in dayEntries {
                    // Check if we need a new page within the day
                    let estimatedHeight = estimateEntryHeight(entry: entry, pageWidth: pageWidth, margin: margin)
                    if currentY + estimatedHeight > pageHeight - margin - 50 {
                        context.beginPage()
                        currentY = margin
                        currentY = drawTableHeader(
                            context: context,
                            pageWidth: pageWidth,
                            margin: margin,
                            y: currentY
                        )
                    }

                    currentY = drawEntry(
                        context: context,
                        entry: entry,
                        pageWidth: pageWidth,
                        pageHeight: pageHeight,
                        margin: margin,
                        y: currentY
                    )
                }

                // Add some spacing after each day's entries
                currentY += 20
            }

            // Summary
            if currentY > pageHeight - margin - 150 {
                context.beginPage()
                currentY = margin
            }
            drawSummary(
                context: context,
                entries: sortedEntries,
                pageWidth: pageWidth,
                margin: margin,
                y: currentY
            )
        }

        return data
    }

    // MARK: - Helper Functions

    private func estimateEntryHeight(entry: MealEntry, pageWidth: CGFloat, margin: CGFloat) -> CGFloat {
        var estimatedHeight: CGFloat = 40 // Minimum row height

        // Estimate image height
        if let imageData = entry.imageData, let image = UIImage(data: imageData) {
            let maxImageWidth: CGFloat = 170
            let maxImageHeight: CGFloat = 120

            let imageSize = image.size
            let aspectRatio = imageSize.width / imageSize.height
            var drawHeight = maxImageWidth / aspectRatio

            if drawHeight > maxImageHeight {
                drawHeight = maxImageHeight
            }

            estimatedHeight = max(estimatedHeight, drawHeight + 10)
        }

        // Estimate text height
        if !entry.foodAndDrink.isEmpty {
            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 11)
            ]
            let textHeight = calculateTextHeight(
                text: entry.foodAndDrink,
                width: 180,
                attributes: textAttributes
            )
            estimatedHeight = max(estimatedHeight, textHeight + 10)
        }

        // Add padding and separator
        return estimatedHeight + 10
    }

    // MARK: - Drawing Functions

    private func drawDayHeader(
        context: UIGraphicsPDFRendererContext,
        date: Date,
        entryCount: Int,
        pageWidth: CGFloat,
        margin: CGFloat,
        y: CGFloat
    ) -> CGFloat {
        var currentY = y

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d, yyyy"
        let dateString = dateFormatter.string(from: date)

        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold),
            .foregroundColor: UIColor.label
        ]

        let subtitle = "\(dateString) (\(entryCount) \(entryCount == 1 ? "entry" : "entries"))"
        subtitle.draw(at: CGPoint(x: margin, y: currentY), withAttributes: titleAttributes)
        currentY += 30

        // Draw line under day header
        context.cgContext.setStrokeColor(UIColor.separator.cgColor)
        context.cgContext.setLineWidth(1.0)
        context.cgContext.move(to: CGPoint(x: margin, y: currentY))
        context.cgContext.addLine(to: CGPoint(x: pageWidth - margin, y: currentY))
        context.cgContext.strokePath()

        return currentY + 15
    }

    private func drawHeader(
        context: UIGraphicsPDFRendererContext,
        dateRange: ClosedRange<Date>,
        userSettings: UserSettings,
        pageWidth: CGFloat,
        margin: CGFloat,
        y: CGFloat
    ) -> CGFloat {
        var currentY = y

        // Title
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 24, weight: .bold),
            .foregroundColor: UIColor.label
        ]
        let title = "Food & Behavior Log"
        title.draw(at: CGPoint(x: margin, y: currentY), withAttributes: titleAttributes)
        currentY += 35

        // Date range
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let dateRangeText = "\(dateFormatter.string(from: dateRange.lowerBound)) - \(dateFormatter.string(from: dateRange.upperBound))"

        let subtitleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.secondaryLabel
        ]
        dateRangeText.draw(at: CGPoint(x: margin, y: currentY), withAttributes: subtitleAttributes)
        currentY += 25

        // Care team info (if available)
        if !userSettings.careTeam.isEmpty {
            let careTeamText = "Care Team:"
            careTeamText.draw(at: CGPoint(x: margin, y: currentY), withAttributes: subtitleAttributes)
            currentY += 20

            for member in userSettings.careTeam {
                let memberText = "  • \(member.name) (\(member.role.rawValue))"
                memberText.draw(at: CGPoint(x: margin, y: currentY), withAttributes: subtitleAttributes)
                currentY += 15

                if let phone = member.phone {
                    let phoneText = "    \(phone)"
                    phoneText.draw(at: CGPoint(x: margin, y: currentY), withAttributes: subtitleAttributes)
                    currentY += 15
                }
            }
        }

        currentY += 10 // Extra spacing
        return currentY
    }

    private func drawTableHeader(
        context: UIGraphicsPDFRendererContext,
        pageWidth: CGFloat,
        margin: CGFloat,
        y: CGFloat
    ) -> CGFloat {
        let headerAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .semibold),
            .foregroundColor: UIColor.label
        ]

        let columns = [
            ("Time", 80.0),
            ("Food & Drink", 180.0),
            ("Place", 80.0),
            ("*", 30.0),
            ("V/L/D/E", 60.0),
            ("Context", 100.0)
        ]

        var x = margin
        for (header, width) in columns {
            header.draw(at: CGPoint(x: x, y: y), withAttributes: headerAttributes)
            x += width
        }

        // Draw line under header
        context.cgContext.setStrokeColor(UIColor.separator.cgColor)
        context.cgContext.setLineWidth(0.5)
        context.cgContext.move(to: CGPoint(x: margin, y: y + 20))
        context.cgContext.addLine(to: CGPoint(x: pageWidth - margin, y: y + 20))
        context.cgContext.strokePath()

        return y + 25
    }

    private func drawEntry(
        context: UIGraphicsPDFRendererContext,
        entry: MealEntry,
        pageWidth: CGFloat,
        pageHeight: CGFloat,
        margin: CGFloat,
        y: CGFloat
    ) -> CGFloat {
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11),
            .foregroundColor: UIColor.label
        ]

        var currentY = y
        let foodColumnX = margin + 80
        let foodColumnWidth: CGFloat = 180
        var foodContentHeight: CGFloat = 0

        // Time
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        timeFormatter.string(from: entry.timestamp).draw(
            in: CGRect(x: margin, y: currentY, width: 80, height: 20),
            withAttributes: textAttributes
        )

        // Food & Drink (with image support)
        var currentFoodY = currentY

        // Draw image if available
        if let imageData = entry.imageData, let image = UIImage(data: imageData) {
            let maxImageWidth = foodColumnWidth - 10
            let maxImageHeight: CGFloat = 120

            // Calculate scaled size to fit within constraints
            let imageSize = image.size
            let aspectRatio = imageSize.width / imageSize.height
            var drawWidth = maxImageWidth
            var drawHeight = drawWidth / aspectRatio

            if drawHeight > maxImageHeight {
                drawHeight = maxImageHeight
                drawWidth = drawHeight * aspectRatio
            }

            // Draw image with border
            let imageRect = CGRect(
                x: foodColumnX + 5,
                y: currentFoodY + 2,
                width: drawWidth,
                height: drawHeight
            )

            // Draw border around image
            context.cgContext.setStrokeColor(UIColor.separator.cgColor)
            context.cgContext.setLineWidth(0.5)
            context.cgContext.stroke(imageRect)

            // Draw the image
            image.draw(in: imageRect)

            currentFoodY += drawHeight + 5
            foodContentHeight = drawHeight + 5
        }

        // Draw food text (if available)
        if !entry.foodAndDrink.isEmpty {
            let textRect = CGRect(
                x: foodColumnX,
                y: currentFoodY,
                width: foodColumnWidth,
                height: 60
            )

            entry.foodAndDrink.draw(
                in: textRect,
                withAttributes: textAttributes
            )

            let textHeight = calculateTextHeight(
                text: entry.foodAndDrink,
                width: foodColumnWidth,
                attributes: textAttributes
            )
            foodContentHeight += textHeight
        } else if entry.imageData == nil {
            // If neither image nor text, show placeholder
            "[No description]".draw(
                in: CGRect(x: foodColumnX, y: currentFoodY, width: foodColumnWidth, height: 20),
                withAttributes: textAttributes
            )
            foodContentHeight = 20
        }

        // Location
        entry.location.draw(
            in: CGRect(x: margin + 260, y: currentY, width: 80, height: 20),
            withAttributes: textAttributes
        )

        // Asterisk if believed excessive
        if entry.believedExcessive == true {
            "*".draw(
                in: CGRect(x: margin + 340, y: currentY, width: 30, height: 20),
                withAttributes: textAttributes
            )
        }

        // Behaviors (V/L/D/E)
        var behaviors = ""
        if entry.vomited { behaviors += "V " }
        if entry.laxativesAmount > 0 { behaviors += "L(\(entry.laxativesAmount)) " }
        if entry.diureticsAmount > 0 { behaviors += "D(\(entry.diureticsAmount)) " }
        if let exercise = entry.exerciseDuration { behaviors += "E(\(exercise)m) " }

        behaviors.draw(
            in: CGRect(x: margin + 370, y: currentY, width: 60, height: 40),
            withAttributes: textAttributes
        )

        // Context (emotions/comments)
        var contextText = ""
        if let emotionsBefore = entry.emotionsBefore, !emotionsBefore.isEmpty {
            contextText += "Before: \(emotionsBefore) "
        }
        if let emotionsAfter = entry.emotionsAfter, !emotionsAfter.isEmpty {
            contextText += "After: \(emotionsAfter) "
        }
        if let thoughts = entry.thoughtsAndFeelings, !thoughts.isEmpty {
            contextText += "Notes: \(thoughts)"
        }

        let contextHeight = calculateTextHeight(text: contextText, width: 100, attributes: textAttributes)
        contextText.draw(
            in: CGRect(x: margin + 430, y: currentY, width: 100, height: max(60, contextHeight)),
            withAttributes: textAttributes
        )

        // Calculate height needed (considering image + text + context)
        let maxHeight = max(40, max(foodContentHeight, contextHeight))
        currentY += maxHeight + 5

        // Draw separator line
        context.cgContext.setStrokeColor(UIColor.separator.withAlphaComponent(0.3).cgColor)
        context.cgContext.setLineWidth(0.25)
        context.cgContext.move(to: CGPoint(x: margin, y: currentY))
        context.cgContext.addLine(to: CGPoint(x: pageWidth - margin, y: currentY))
        context.cgContext.strokePath()

        return currentY + 5
    }

    private func drawSummary(
        context: UIGraphicsPDFRendererContext,
        entries: [MealEntry],
        pageWidth: CGFloat,
        margin: CGFloat,
        y: CGFloat
    ) {
        var currentY = y + 30

        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .semibold),
            .foregroundColor: UIColor.label
        ]

        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.secondaryLabel
        ]

        "Summary".draw(at: CGPoint(x: margin, y: currentY), withAttributes: titleAttributes)
        currentY += 25

        // Total entries
        "Total entries: \(entries.count)".draw(
            at: CGPoint(x: margin, y: currentY),
            withAttributes: textAttributes
        )
        currentY += 20

        // Behavior counts
        let vomitCount = entries.filter { $0.vomited }.count
        if vomitCount > 0 {
            "Vomiting episodes: \(vomitCount)".draw(
                at: CGPoint(x: margin, y: currentY),
                withAttributes: textAttributes
            )
            currentY += 20
        }

        let laxativeEntries = entries.filter { $0.laxativesAmount > 0 }
        if !laxativeEntries.isEmpty {
            let total = laxativeEntries.map { $0.laxativesAmount }.reduce(0, +)
            "Laxative use: \(laxativeEntries.count) times, total: \(total)".draw(
                at: CGPoint(x: margin, y: currentY),
                withAttributes: textAttributes
            )
            currentY += 20
        }

        let diureticEntries = entries.filter { $0.diureticsAmount > 0 }
        if !diureticEntries.isEmpty {
            let total = diureticEntries.map { $0.diureticsAmount }.reduce(0, +)
            "Diuretic use: \(diureticEntries.count) times, total: \(total)".draw(
                at: CGPoint(x: margin, y: currentY),
                withAttributes: textAttributes
            )
            currentY += 20
        }

        let exerciseEntries = entries.compactMap { $0.exerciseDuration }
        if !exerciseEntries.isEmpty {
            let total = exerciseEntries.reduce(0, +)
            "Exercise: \(exerciseEntries.count) times, total: \(total) minutes".draw(
                at: CGPoint(x: margin, y: currentY),
                withAttributes: textAttributes
            )
            currentY += 20
        }

        // Believed excessive count
        let excessiveCount = entries.filter { $0.believedExcessive == true }.count
        if excessiveCount > 0 {
            "Entries marked as excessive: \(excessiveCount)".draw(
                at: CGPoint(x: margin, y: currentY),
                withAttributes: textAttributes
            )
            currentY += 20
        }

        // Footer
        currentY += 20
        let footerAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.tertiaryLabel
        ]

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        "Generated on \(dateFormatter.string(from: Date()))".draw(
            at: CGPoint(x: margin, y: currentY),
            withAttributes: footerAttributes
        )

        currentY += 15
        "Monitor - Self-Monitoring Tool".draw(
            at: CGPoint(x: margin, y: currentY),
            withAttributes: footerAttributes
        )

        // Legend
        currentY += 25
        "* = Believed excessive | V = Vomiting | L = Laxatives | D = Diuretics | E = Exercise".draw(
            at: CGPoint(x: margin, y: currentY),
            withAttributes: footerAttributes
        )
    }

    private func calculateTextHeight(text: String, width: CGFloat, attributes: [NSAttributedString.Key: Any]) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(
            with: constraintRect,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes,
            context: nil
        )
        return ceil(boundingBox.height)
    }
}