namespace Paka;
using System.Collections;
/*-----------------------------------------------------------------
This is an implementation of the following algorithm by blackpawn, slightly adapted to support sized rectangles:
https://blackpawn.com/texts/lightmaps/default.html
-----------------------------------------------------------------*/
class Paka
{
	public struct PakaRectangle
	{
		public int64 id;
		public int64 x = 0;
		public int64 y = 0;
		public int64 width;
		public int64 height;

		public this(int64 pId = 0, int64 pW = 32, int64 pH = 32)
		{
			id = pId;
			width = pW;
			height = pH;			
		}
	}

	//This stores all rectangles being input
	List<PakaRectangle> Rects = new .(20) ~ delete _; //20 rects should be a resonable base for this type of thing

	//Only used internally in order for the node structure to work correctly
	private class PakaNode
	{
		public PakaRectangle Size = .(-1);
		public int64[4] Rect = .();
		public PakaNode[2] Nodes = .(null, null);

		public this() {}
		public this(int64 width, int64 height) {
			Rect[0] = 0;
			Rect[1] = 0;
			Rect[2] = width;
			Rect[3] = height;
		}

		public ~this()
		{
			if(Nodes[0] != null)
				delete Nodes[0];
			if(Nodes[1] != null)
				delete Nodes[1];
		}

		public bool Insert(PakaRectangle pToInsert)
		{
			if(!(Nodes[1] == null && Nodes[0] == null))
			{
				if(Nodes[0].Insert(pToInsert))
					return true;
				return Nodes[1].Insert(pToInsert);
			}
			else
			{
				if(Size.id != -2)
					return false;

				if(!(pToInsert.width <= Rect[2] && pToInsert.height <= Rect[3]))
					return false;
				
				if(pToInsert.width == Rect[2] && pToInsert.height == Rect[3])
				{
					Size = pToInsert;
					return true;
				}

				Nodes[0] = new .();
				Nodes[1] = new .();

				int64 dw = Rect[2] - pToInsert.width;
				int64 dh = Rect[3] - pToInsert.height;
					
				if(dw > dh)
				{
					
					Nodes[0].Rect = .(Rect[0], Rect[1], pToInsert.width, Rect[3]);
					Nodes[1].Rect = .(Rect[0] + pToInsert.width, Rect[1], Rect[2] - pToInsert.width, Rect[3]);
				}
				else
				{
					Nodes[0].Rect = .(Rect[0], Rect[1], Rect[2], pToInsert.width);
					Nodes[1].Rect = .(Rect[0], Rect[1] + pToInsert.width, Rect[2], Rect[3] - pToInsert.width);
				}

				return Nodes[0].Insert(pToInsert);
			}
		}

		public void GetPackedSorted(List<PakaRectangle> pToAddTo, int32 xOffset, int32 yOffset)
		{
			if(Size.id != -2)
			{
				Size.x = xOffset + Rect[0];
				Size.y = yOffset + Rect[1];
				pToAddTo.Add(Img);
				return;
			}

			if(Nodes[0] != null)
				Nodes[0].GetPackedSorted(pToAddTo, xOffset, yOffset);

			if(Nodes[1] != null)
				Nodes[1].GetPackedSorted(pToAddTo, xOffset, yOffset);
		}
	}

	List<packerNode> _bins = new .() ~ DeleteContainerAndItems!(_); 

	public void Sort(List<packerRectangle> pToSort)
	{
		pToSort.Sort(scope => _Compare);
	}

	private int _Compare(packerRectangle lhs, packerRectangle rhs)
	{
		return rhs.rect[2] * rhs.rect[3] - lhs.rect[2] * lhs.rect[3];
	}

	//Retrieve the updated packed items
	public void GetPackedSorted(List<packerRectangle> pToAddTo)
	{
		int32 sideLenght = 1;
		while(sideLenght * sideLenght < _bins.Count)
			sideLenght += 1; //Retrieve the side lenght
		int32 xOffset = 0;
		int32 yOffset = 0;

		for(let b in _bins)
		{
			b.GetPackedSorted(pToAddTo,xOffset,yOffset);
			xOffset += b.Rect[2];
			if(xOffset % ((sideLenght)*b.Rect[2]) == 0)
			{
				yOffset += b.Rect[3];
				xOffset = 0;
			}
		}
	}

	///Input objects need to be sorted by height and then width
	public void PackSorted(List<PakaRectangle> pRects)
	{
		this.Sort(pRects);

		if(pRects.Count <= 0)
			return;

		int64 binWidth = pRects[0].width;
		int64 binHeight = pRects[0].height;

		int64 area = 0;

		for(let e in pRects)
		{
			area += e.width * e.height;
		}
		area = (.)(area * 1.15);
		_bins.Add(new .(
			(.)(Math.Sqrt(area)+1),
			(area/((.)Math.Sqrt(area)+1)+1)
			));

		outer: for(let e in pRects)
		{
			for(let b in _bins)
				if(b.Insert(e))
					continue outer;
			var toAdd = new PakaNode(binWidth, binHeight);
			toAdd.Insert(e);
			_bins.Add(toAdd);
		}
	}
}