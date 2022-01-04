points := OrderedCollection new.
alreadyDrawn := 0.
anElement := BlElement new
	constraintsDo: [:c|
		c vertical matchParent.
		c horizontal matchParent.].
anElement addChild: (BlElement new);
when: BlDragStartEvent do: [:anEvent| | currentTask |
	anEvent consumed: true. currentTask := task value.
	anElement userData at: #currentTask put: currentTask. anElement enqueueTask: currentTask.
	points add:{anEvent localPosition. OrderedCollection new}];
when: BlDragEvent do: [:anEvent|
	anEvent consumed: true. points last second add: anEvent localPosition.];
when: BlDragEndEvent do: [:anEvent|
	anEvent consumed: true. anElement dequeueTask: (anElement userData at: #currentTask).
	points last second add: anEvent localPosition].
task := [ BlRepeatedTaskAction new
			delay: 0 milliSeconds;
			action: [
				| justDrew newElement |
				(points sum: [:each| each second size]) ~= alreadyDrawn ifTrue: [
					justDrew := 0.
					newElement := BlSpartaElement new
						rendering: [ :aCanvas :aSpartaElement |
							| aPath spartaPathBuilder spartaSTrokeBuilder |
							spartaPathBuilder := aCanvas path.
							points do: [:lineSegment|
								spartaPathBuilder moveTo: lineSegment first.
								lineSegment second do: [:point|
									spartaPathBuilder lineTo: point.
									justDrew := justDrew + 1.
								].
							].
							aPath := spartaPathBuilder finish.
							spartaSTrokeBuilder := aCanvas stroke.
							spartaSTrokeBuilder paint: Color black;
							path: aPath;
							width: 2;
							draw.
							].
					alreadyDrawn := justDrew.
					anElement replaceChild: anElement children first with: newElement.
					]	
			].
		].
anElement
